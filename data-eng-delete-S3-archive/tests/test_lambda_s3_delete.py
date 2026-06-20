import importlib
import os
import sys
import unittest
from pathlib import Path

from botocore.exceptions import ClientError


os.environ.setdefault("AWS_DEFAULT_REGION", "eu-west-1")
os.environ.setdefault("AWS_EC2_METADATA_DISABLED", "true")

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))


class FakeS3Client:
    def __init__(self, existing_objects):
        self.existing_objects = existing_objects
        self.deleted_objects = []

    def head_object(self, Bucket, Key):
        object_metadata = self.existing_objects.get((Bucket, Key))
        if object_metadata is None:
            raise ClientError(
                {"Error": {"Code": "404", "Message": "Not Found"}},
                "HeadObject",
            )

        return object_metadata

    def delete_object(self, Bucket, Key):
        self.deleted_objects.append((Bucket, Key))
        return {"ResponseMetadata": {"HTTPStatusCode": 204}}


class Context:
    aws_request_id = "test-request-id"


def s3_event(bucket, key):
    return {
        "Records": [
            {
                "s3": {
                    "bucket": {"name": bucket},
                    "object": {"key": key},
                }
            }
        ]
    }


class LambdaS3DeleteTests(unittest.TestCase):
    def setUp(self):
        os.environ["TARGET_BUCKET"] = "bi-staging.tenproduct.com"
        os.environ["ARCHIVE_ROOTS"] = "CMS,ivector"
        os.environ["ARCHIVE_FOLDER"] = "sql-archive"
        os.environ["TARGET_FOLDER"] = "incoming"
        os.environ["DELETE_TARGET"] = "true"

        if "lambda_s3_delete" in sys.modules:
            del sys.modules["lambda_s3_delete"]

        self.lambda_module = importlib.import_module("lambda_s3_delete")

    def test_build_target_key_maps_sql_archive_to_incoming_and_strips_date_folder(self):
        target_key = self.lambda_module.build_target_key("CMS/sql-archive/20260419/Dining.csv")

        self.assertEqual(target_key, "CMS/incoming/Dining.csv")

    def test_build_target_key_preserves_nested_path_without_date_folder(self):
        target_key = self.lambda_module.build_target_key("ivector/sql-archive/outbound/file.csv")

        self.assertEqual(target_key, "ivector/incoming/outbound/file.csv")

    def test_lambda_handler_deletes_matching_incoming_object(self):
        bucket = "bi-staging.tenproduct.com"
        source_key = "CMS/sql-archive/20260419/Dining.csv"
        target_key = "CMS/incoming/Dining.csv"
        fake_s3 = FakeS3Client({
            (bucket, source_key): {"ContentLength": 100},
            (bucket, target_key): {
                "ContentLength": 90,
                "ContentType": "text/csv",
                "ETag": '"abc123"',
            },
        })
        self.lambda_module.s3 = fake_s3

        response = self.lambda_module.lambda_handler(s3_event(bucket, source_key), Context())

        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(fake_s3.deleted_objects, [(bucket, target_key)])

    def test_lambda_handler_skips_delete_when_target_is_missing(self):
        bucket = "bi-staging.tenproduct.com"
        source_key = "CMS/sql-archive/20260419/Dining.csv"
        fake_s3 = FakeS3Client({
            (bucket, source_key): {"ContentLength": 100},
        })
        self.lambda_module.s3 = fake_s3

        response = self.lambda_module.lambda_handler(s3_event(bucket, source_key), Context())

        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(fake_s3.deleted_objects, [])
        self.assertIn("target_missing", response["body"])


if __name__ == "__main__":
    unittest.main()
