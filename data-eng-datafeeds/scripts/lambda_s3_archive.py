# S3-triggered Lambda function to copy objects from source bucket
# to archive prefix in target bucket,with verification and optional deletion of source.

from __future__ import print_function

import os
import json
import logging
from urllib.parse import unquote_plus

import boto3
from botocore.exceptions import ClientError

# Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS client
s3 = boto3.client("s3")

# Lambda config Environment variables
LANDING_BUCKET = os.environ.get("LANDING_BUCKET") #the main bucket where we delete files
TARGET_PREFIX = os.environ.get("TARGET_PREFIX", "archive/") # prefix here we delete files
DELETE_LANDING = os.environ.get("DELETE_TARGET", "true").lower() == "true"

def lambda_handler(event, context):
    """
    S3-triggered Lambda:
    1. Reads uploaded object event in archive folder
    4. Deletes source object only after successful verification
    """

    if not LANDING_BUCKET:
        raise ValueError("Missing required environment variable: TARGET_BUCKET")

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
    Process one S3 event record.
    """

    source_bucket = record["s3"]["bucket"]["name"] # archive directory where file copied to
    raw_key = record["s3"]["object"]["key"]
    object_key = unquote_plus(raw_key)

    target_key = build_target_key(object_key)

    logger.info("Processing object")
    logger.info("Source bucket: %s", source_bucket)
    logger.info("Source key: %s", object_key)
    logger.info("Target bucket: %s", LANDING_BUCKET)
    logger.info("Target key: %s", target_key)

    # Prevent accidental self-copy loops
    if source_bucket == LANDING_BUCKET and object_key == target_key:
        raise ValueError("Source and target object are identical. Refusing to continue.")

    copy_source = {
        "Bucket": source_bucket,
        "Key": object_key
    }

    # -------------------------------------------------------------------------
    # Step 1: Confirm source object exists
    # -------------------------------------------------------------------------
    source_head = safe_head_object(source_bucket, object_key)
    if source_head is None:
        logger.warning("Source object missing: s3://%s/%s", source_bucket, object_key)
        return {
            "action": "skipped_source_missing",
            "source_bucket": source_bucket,
            "source_key": object_key,
            "target_bucket": LANDING_BUCKET,
            "target_key": target_key
        }

    source_size = source_head.get("ContentLength")
    source_etag = source_head.get("ETag")
    source_content_type = source_head.get("ContentType")

    logger.info(
        "Source object found. Size=%s ETag=%s ContentType=%s",
        source_size,
        source_etag,
        source_content_type
    )

    # -------------------------------------------------------------------------
    # Step 2: Check whether target already exists (idempotency)
    # -------------------------------------------------------------------------
    existing_target_head = safe_head_object(LANDING_BUCKET, target_key)
    if existing_target_head is not None:
        target_size = existing_target_head.get("ContentLength")
        logger.info("Target already exists. Target size=%s", target_size)

        if target_size == source_size:
            logger.info("Target already has matching object")

            if DELETE_TARGET:
                logger.info("Deleting source object because matching target already exists")
                safe_delete_object(source_bucket, object_key)
                action = "already_copied_deleted_source"
            else:
                action = "already_copied_kept_source"

            return {
                "action": action,
                "source_bucket": source_bucket,
                "source_key": object_key,
                "target_bucket": LANDING_BUCKET,
                "target_key": target_key,
                "source_size": source_size,
                "target_size": target_size,
                "content_type": source_content_type
            }

        logger.warning("Target exists but size differs. Overwriting target object.")

    # -------------------------------------------------------------------------
    # Step 3: Copy object
    # -------------------------------------------------------------------------
    logger.info("Copying object to target")
    copy_response = s3.copy_object(
        CopySource=copy_source,
        Bucket=LANDING_BUCKET,
        Key=target_key
    )
    logger.info("Copy response: %s", json.dumps(copy_response, default=str))

    # -------------------------------------------------------------------------
    # Step 4: Verify copied object exists in target
    # -------------------------------------------------------------------------
    target_head = safe_head_object(LANDING_BUCKET, target_key)
    if target_head is None:
        raise RuntimeError(
            f"Copied object not found in target bucket: s3://{LANDING_BUCKET}/{target_key}"
        )

    target_size = target_head.get("ContentLength")
    target_etag = target_head.get("ETag")
    target_content_type = target_head.get("ContentType")

    logger.info(
        "Target object found. Size=%s ETag=%s ContentType=%s",
        target_size,
        target_etag,
        target_content_type
    )

    if target_size != source_size:
        raise RuntimeError(
            f"Copy verification failed for {object_key}. "
            f"Source size={source_size}, target size={target_size}"
        )

    # ETag is useful, but may differ in some S3/KMS/multipart scenarios
    if source_etag and target_etag and source_etag != target_etag:
        logger.warning(
            "ETag mismatch detected. Source ETag=%s, Target ETag=%s",
            source_etag,
            target_etag
        )

    # -------------------------------------------------------------------------
    # Step 5: Delete source only after verification
    # -------------------------------------------------------------------------
    if DELETE_TARGET:
        logger.info("Deleting source object")
        safe_delete_object(source_bucket, object_key)
        action = "copied_and_deleted"
    else:
        logger.info("DELETE_SOURCE is false. Source retained.")
        action = "copied_only"

    return {
        "action": action,
        "source_bucket": source_bucket,
        "source_key": object_key,
        "target_bucket": LANDING_BUCKET,
        "target_key": target_key,
        "source_size": source_size,
        "target_size": target_size,
        "source_content_type": source_content_type,
        "target_content_type": target_content_type,
        "copy_result": copy_response.get("CopyObjectResult", {})
    }


def build_target_key(object_key):
    """
    Build archive target key safely.
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
    Delete object from source bucket.
    """
    try:
        s3.delete_object(Bucket=bucket, Key=key)
        logger.info("Deleted source object: s3://%s/%s", bucket, key)
    except ClientError:
        logger.exception("Failed to delete source object: s3://%s/%s", bucket, key)
        raise