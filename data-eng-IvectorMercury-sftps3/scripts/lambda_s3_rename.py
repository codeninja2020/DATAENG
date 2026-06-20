import json
import logging
import os
import re
from urllib.parse import unquote_plus

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")

# Terraform passes the destination bucket and watched root prefixes as environment variables.
BUCKET = os.environ["BUCKET"]
ROOTS = [
    root.strip().rstrip("/")
    for root in os.environ.get("ROOTS", "").split(",")
    if root.strip()
]


def lambda_handler(event, context):
    logger.info("Lambda invoked")
    logger.info("Request ID: %s", context.aws_request_id)
    logger.info("Received event: %s", json.dumps(event))

    # S3 notifications include one or more object records; empty events are treated as no-ops.
    records = event.get("Records", [])
    if not records:
        logger.warning("No Records found in event")
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "No records to process", "results": []}),
        }

    results = []
    failed_records = []

    # Process each record independently so all failures are logged before the Lambda fails.
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
        logger.error("Failed records: %s", json.dumps(failed_records, default=str))
        raise RuntimeError(f"Failed to process {len(failed_records)} of {len(records)} record(s)")

    return {"statusCode": 200, "body": json.dumps(results, default=str)}


def process_record(record):
    # S3 object keys arrive URL-encoded in event notifications.
    source_bucket = record["s3"]["bucket"]["name"]
    source_key = unquote_plus(record["s3"]["object"]["key"])
    target_key = build_target_key(source_key)

    logger.info("Source: s3://%s/%s", source_bucket, source_key)
    logger.info("Target: s3://%s/%s", BUCKET, target_key)

    if source_bucket == BUCKET and source_key == target_key:
        logger.info("Filename already clean; skipping.")
        return {
            "action": "skipped",
            "source_key": source_key,
            "target_key": target_key,
        }

    # S3 has no native rename operation, so copy to the clean key and then delete the original.
    s3.copy_object(
        Bucket=BUCKET,
        Key=target_key,
        CopySource={
            "Bucket": source_bucket,
            "Key": source_key,
        },
    )
    logger.info("Copied to s3://%s/%s", BUCKET, target_key)

    s3.delete_object(Bucket=source_bucket, Key=source_key)
    logger.info("Deleted s3://%s/%s", source_bucket, source_key)

    return {
        "action": "renamed",
        "source_key": source_key,
        "target_key": target_key,
    }


def build_target_key(object_key):
    """Return the renamed key, keeping files under the configured incoming prefix."""
    for root in ROOTS:
        prefix = f"{root}/"
        if object_key.startswith(prefix):
            remainder = object_key[len(prefix):]
            last_separator = remainder.rfind("/")
            if last_separator == -1:
                directory = ""
                filename = remainder
            else:
                directory = remainder[:last_separator + 1]
                filename = remainder[last_separator + 1:]
            return f"{root}/{directory}{strip_trailing_non_letters(filename)}"

    raise ValueError(f"Object key does not match any configured root: {object_key}")


def strip_trailing_non_letters(filename):
    """Strip upload timestamps from the stem while preserving the file extension."""
    stem, extension = os.path.splitext(filename)
    stem = re.sub(r"[\s_.-]*v[^a-zA-Z]+$", "", stem, flags=re.IGNORECASE)

    # Keep all characters through the final letter and remove any trailing non-letter suffix.
    match = re.search(r"[a-zA-Z](?=[^a-zA-Z]*$)", stem)
    if not match:
        return filename

    return f"{stem[:match.end()]}{extension}"
