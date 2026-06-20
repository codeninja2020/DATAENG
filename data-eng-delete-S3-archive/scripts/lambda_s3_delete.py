import json
import logging
import os
import re
from urllib.parse import unquote_plus

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")


def _normalize_prefix(prefix):
    prefix = (prefix or "").strip()
    if prefix and not prefix.endswith("/"):
        prefix = f"{prefix}/"
    return prefix


TARGET_BUCKET = os.environ.get("TARGET_BUCKET") or os.environ.get("LANDING_BUCKET")
ARCHIVE_ROOTS = [
    _normalize_prefix(root)
    for root in os.environ.get("ARCHIVE_ROOTS", "CMS").split(",")
    if root.strip()
]
ARCHIVE_FOLDER = _normalize_prefix(os.environ.get("ARCHIVE_FOLDER", "sql-archive")).strip("/")
TARGET_FOLDER = _normalize_prefix(os.environ.get("TARGET_FOLDER", "incoming"))
TARGET_PREFIX = _normalize_prefix(os.environ.get("TARGET_PREFIX", "CMS/"))
SOURCE_PREFIX_STRIP = _normalize_prefix(os.environ.get("SOURCE_PREFIX_STRIP", f"CMS/{ARCHIVE_FOLDER}/"))
DELETE_TARGET = os.environ.get("DELETE_TARGET", os.environ.get("DELETE_SOURCE", "true")).lower() == "true"


def lambda_handler(event, context):
    if not TARGET_BUCKET:
        raise ValueError("Missing required environment variable: TARGET_BUCKET (or legacy LANDING_BUCKET)")

    logger.info("Lambda invoked")
    logger.info("Request ID: %s", context.aws_request_id)
    logger.info("Received event: %s", json.dumps(event))

    records = event.get("Records", [])
    if not records:
        logger.warning("No Records found in event")
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "No records to process", "results": []}),
        }

    results = []
    failed_records = []
    for record in records:
        try:
            results.append({"status": "success", "result": process_record(record)})
        except Exception as exc:
            logger.exception("Failed to process record")
            results.append({"status": "error", "error": str(exc)})
            failed_records.append({
                "bucket": record.get("s3", {}).get("bucket", {}).get("name"),
                "key": record.get("s3", {}).get("object", {}).get("key"),
                "error": str(exc),
            })

    if failed_records:
        logger.error("One or more records failed: %s", json.dumps(failed_records, default=str))
        raise RuntimeError(f"Failed to process {len(failed_records)} of {len(records)} S3 record(s)")

    return {"statusCode": 200, "body": json.dumps(results, default=str)}


def process_record(record):
    source_bucket = record["s3"]["bucket"]["name"]
    object_key = unquote_plus(record["s3"]["object"]["key"])
    target_key = build_target_key(object_key)

    logger.info("Source bucket: %s", source_bucket)
    logger.info("Source key: %s", object_key)
    logger.info("Target bucket: %s", TARGET_BUCKET)
    logger.info("Target key: %s", target_key)

    if TARGET_PREFIX and not SOURCE_PREFIX_STRIP and object_key.startswith(TARGET_PREFIX):
        logger.info("Object already under target prefix; skipping recursion.")
        return {
            "action": "skip_archive_prefix",
            "source_bucket": source_bucket,
            "source_key": object_key,
            "target_bucket": TARGET_BUCKET,
            "target_key": target_key,
        }

    if source_bucket == TARGET_BUCKET and object_key == target_key:
        raise ValueError("Source and target object are identical. Refusing to delete.")

    source_head = safe_head_object(source_bucket, object_key)
    if source_head is None:
        logger.info("Source object missing; nothing to do: s3://%s/%s", source_bucket, object_key)
        return {
            "action": "source_missing",
            "source_bucket": source_bucket,
            "source_key": object_key,
            "target_bucket": TARGET_BUCKET,
            "target_key": target_key,
        }

    target_head = safe_head_object(TARGET_BUCKET, target_key)
    if target_head is None:
        logger.info("Target object missing; nothing to delete: s3://%s/%s", TARGET_BUCKET, target_key)
        return {
            "action": "target_missing",
            "source_bucket": source_bucket,
            "source_key": object_key,
            "target_bucket": TARGET_BUCKET,
            "target_key": target_key,
        }

    target_size = target_head.get("ContentLength")
    target_etag = target_head.get("ETag")
    target_content_type = target_head.get("ContentType")

    if not DELETE_TARGET:
        logger.info("DELETE_TARGET is false. Target retained.")
        return {
            "action": "target_found_retained",
            "source_bucket": source_bucket,
            "source_key": object_key,
            "target_bucket": TARGET_BUCKET,
            "target_key": target_key,
            "source_size": source_head.get("ContentLength"),
            "target_size": target_size,
            "target_content_type": target_content_type,
        }

    safe_delete_object(TARGET_BUCKET, target_key)
    return {
        "action": "deleted_target",
        "source_bucket": source_bucket,
        "source_key": object_key,
        "target_bucket": TARGET_BUCKET,
        "target_key": target_key,
        "source_size": source_head.get("ContentLength"),
        "target_size": target_size,
        "target_content_type": target_content_type,
        "target_etag": target_etag,
    }


def build_target_key(object_key):
    for archive_root in ARCHIVE_ROOTS:
        archive_prefix = f"{archive_root}{ARCHIVE_FOLDER}/"
        if object_key.startswith(archive_prefix):
            archived_path = object_key[len(archive_prefix):]
            return f"{archive_root}{TARGET_FOLDER}{strip_archive_date_prefix(archived_path)}"

    return build_legacy_target_key(object_key)


def strip_archive_date_prefix(path):
    parts = path.split("/", 1)
    if len(parts) == 2 and re.fullmatch(r"\d{8}", parts[0]):
        return parts[1]

    return path


def build_legacy_target_key(object_key):
    trimmed_key = object_key
    if SOURCE_PREFIX_STRIP and trimmed_key.startswith(SOURCE_PREFIX_STRIP):
        trimmed_key = trimmed_key[len(SOURCE_PREFIX_STRIP):]

    if not TARGET_PREFIX:
        return trimmed_key

    return f"{TARGET_PREFIX}{trimmed_key}"


def safe_head_object(bucket, key):
    try:
        return s3.head_object(Bucket=bucket, Key=key)
    except ClientError as exc:
        error_code = exc.response.get("Error", {}).get("Code", "")
        if error_code in ("404", "NoSuchKey", "NotFound"):
            return None
        raise


def safe_delete_object(bucket, key):
    try:
        s3.delete_object(Bucket=bucket, Key=key)
        logger.info("Deleted object: s3://%s/%s", bucket, key)
    except ClientError:
        logger.exception("Failed to delete object: s3://%s/%s", bucket, key)
        raise
