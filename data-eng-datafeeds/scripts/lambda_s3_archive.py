# S3-triggered Lambda function that deletes a matching object in the target bucket
# when a new object arrives in the source bucket.

from __future__ import print_function

import json
import logging
import os
from urllib.parse import unquote_plus

import boto3
from botocore.exceptions import ClientError

# Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS client
s3 = boto3.client("s3")

# Lambda config Environment variables
# Accept either TARGET_BUCKET or legacy LANDING_BUCKET for compatibility.
TARGET_BUCKET = os.environ.get("TARGET_BUCKET") or os.environ.get("LANDING_BUCKET")
TARGET_PREFIX = os.environ.get("TARGET_PREFIX", "archive/")
# DELETE_TARGET controls whether the matching object in the target bucket is removed.
DELETE_TARGET = os.environ.get("DELETE_TARGET", os.environ.get("DELETE_SOURCE", "true")).lower() == "true"


def lambda_handler(event, context):
    """
    S3-triggered Lambda:
    1. Reads uploaded object event.
    2. Looks for the matching object in the target bucket
    3. Deletes the target object if found (and deletion is enabled).
    """

    if not TARGET_BUCKET:
        raise ValueError("Missing required environment variable: TARGET_BUCKET (or legacy LANDING_BUCKET)")

    logger.info("Lambda invoked")
    logger.info("Request ID: %s", context.aws_request_id)
    logger.info("Log Group: %s", context.log_group_name)
    logger.info("Log Stream: %s", context.log_stream_name)
    logger.info("Memory Limit (MB): %s", context.memory_limit_in_mb)
    logger.info("Received event: %s", json.dumps(event))

    records = event.get("Records", [])

    if not records:
        logger.warning("No Records found in event")
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "No records to process",
                "results": []
            })
        }

    results = []

    for record in records:
        try:
            result = process_record(record)
            results.append({
                "status": "success",
                "result": result
            })
        except Exception as exc:
            logger.exception("Failed to process record")
            results.append({
                "status": "error",
                "error": str(exc)
            })

    return {
        "statusCode": 200,
        "body": json.dumps(results, default=str)
    }


def process_record(record):
    """
    Process one S3 event record: delete matching object from the target bucket if present.
    """

    source_bucket = record["s3"]["bucket"]["name"]
    raw_key = record["s3"]["object"]["key"]
    object_key = unquote_plus(raw_key)

    target_key = build_target_key(object_key)

    logger.info("Processing object")
    logger.info("Source bucket: %s", source_bucket)
    logger.info("Source key: %s", object_key)
    logger.info("Target bucket: %s", TARGET_BUCKET)
    logger.info("Target key: %s", target_key)

    # Prevent accidental self-deletion of the just-uploaded object when bucket/prefix align.
    if source_bucket == TARGET_BUCKET and object_key == target_key:
        raise ValueError("Source and target object are identical. Refusing to delete.")

    # Confirm source exists (event could be stale or already deleted)
    source_head = safe_head_object(source_bucket, object_key)
    if source_head is None:
        logger.info("Source object missing; nothing to do: s3://%s/%s", source_bucket, object_key)
        return {
            "action": "source_missing",
            "source_bucket": source_bucket,
            "source_key": object_key,
            "target_bucket": TARGET_BUCKET,
            "target_key": target_key
        }

    # Step 2: Check whether target exists
    target_head = safe_head_object(TARGET_BUCKET, target_key)
    if target_head is None:
        logger.info("Target object missing; nothing to delete: s3://%s/%s", TARGET_BUCKET, target_key)
        return {
            "action": "target_missing",
            "source_bucket": source_bucket,
            "source_key": object_key,
            "target_bucket": TARGET_BUCKET,
            "target_key": target_key
        }

    target_size = target_head.get("ContentLength")
    target_etag = target_head.get("ETag")
    target_content_type = target_head.get("ContentType")

    logger.info(
        "Target object found. Size=%s ETag=%s ContentType=%s",
        target_size,
        target_etag,
        target_content_type
    )

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
            "target_content_type": target_content_type
        }

    # Delete target object
    safe_delete_object(TARGET_BUCKET, target_key)
    action = "deleted_target"

    return {
        "action": action,
        "source_bucket": source_bucket,
        "source_key": object_key,
        "target_bucket": TARGET_BUCKET,
        "target_key": target_key,
        "source_size": source_head.get("ContentLength"),
        "target_size": target_size,
        "target_content_type": target_content_type,
        "target_etag": target_etag
    }


def build_target_key(object_key):
    """
    Build target key safely.
    Example:
        source key: reports/file.csv
        target key: archive/reports/file.csv
    """
    prefix = TARGET_PREFIX.strip()

    if not prefix:
        return object_key

    if not prefix.endswith("/"):
        prefix = prefix + "/"

    return f"{prefix}{object_key}"


def safe_head_object(bucket, key):
    """
    Return head_object metadata or None if object does not exist.
    """
    try:
        return s3.head_object(Bucket=bucket, Key=key)
    except ClientError as exc:
        error_code = exc.response.get("Error", {}).get("Code", "")
        if error_code in ("404", "NoSuchKey", "NotFound"):
            return None
        raise


def safe_delete_object(bucket, key):
    """
    Delete object from specified bucket.
    """
    try:
        s3.delete_object(Bucket=bucket, Key=key)
        logger.info("Deleted object: s3://%s/%s", bucket, key)
    except ClientError:
        logger.exception("Failed to delete object: s3://%s/%s", bucket, key)
        raise
