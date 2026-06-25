import importlib
from io import BytesIO
import json
import os
import sys
import unittest
from pathlib import Path


os.environ.setdefault("AWS_DEFAULT_REGION", "eu-west-1")
os.environ.setdefault("AWS_EC2_METADATA_DISABLED", "true")
os.environ.setdefault("ERROR_BUCKET", "bi-qa.tenproduct.com")
os.environ.setdefault("DB_SECRET_ARN", "arn:aws:secretsmanager:eu-west-1:123456789012:secret:test")
os.environ.setdefault("RULES_BUCKET", "bi-qa.tenproduct.com")
os.environ.setdefault("RULES_KEY", "rpin-data-quality/rules/rpin_checks.csv")
os.environ.setdefault(
    "DB_CONNECTION_URL",
    "jdbc:sqlserver://tenmaid-v1-db-qa.example.com:1433;databaseName=TENMAID_UAT;encrypt=true",
)

REPO_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = REPO_ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS_DIR))


class FakeSecretsManager:
    def get_secret_value(self, SecretId):
        return {
            "SecretString": json.dumps(
                {
                    "username": "test-user",
                    "password": "test-password",
                }
            )
        }


class FakeCloudWatch:
    def __init__(self):
        self.metric_data = []

    def put_metric_data(self, **kwargs):
        self.metric_data.append(kwargs)


class FakeS3:
    def __init__(self):
        self.objects = []
        self.source_objects = {
            (
                "bi-qa.tenproduct.com",
                "rpin-data-quality/rules/rpin_checks.csv",
            ): "check_name,sql_check,table,operator,expected_value\nrpin-reference1-required,\"SELECT 1 AS finding\",dbo.Members,=,0\n",
        }

    def put_object(self, **kwargs):
        self.objects.append(kwargs)

    def get_object(self, Bucket, Key):
        return {
            "Body": BytesIO(self.source_objects[(Bucket, Key)].encode("utf-8")),
        }


class FakeBoto3:
    def __init__(self):
        self.cloudwatch = FakeCloudWatch()
        self.s3 = FakeS3()

    def client(self, service_name, region_name=None):
        if service_name == "secretsmanager":
            return FakeSecretsManager()
        if service_name == "cloudwatch":
            return self.cloudwatch
        if service_name == "s3":
            return self.s3
        raise ValueError(service_name)


class FakeCursor:
    def __init__(self, rows):
        self.rows = rows
        self.sql = None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, traceback):
        return False

    def execute(self, sql):
        self.sql = sql

    def fetchall(self):
        return self.rows


class FakeConnection:
    def __init__(self, rows):
        self.rows = rows

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, traceback):
        return False

    def cursor(self, as_dict=False):
        return FakeCursor(self.rows)


class FakePymssql:
    def __init__(self, rows, connect_error=None):
        self.rows = rows
        self.connect_error = connect_error
        self.connection_args = None

    def connect(self, **kwargs):
        if self.connect_error:
            raise self.connect_error
        self.connection_args = kwargs
        return FakeConnection(self.rows)


class Context:
    aws_request_id = "test-request-id"


class RpinDataQualityTests(unittest.TestCase):
    def setUp(self):
        self.fake_boto3 = FakeBoto3()
        sys.modules["boto3"] = self.fake_boto3

        if "rpin_data_quality" in sys.modules:
            del sys.modules["rpin_data_quality"]

        self.lambda_module = importlib.import_module("rpin_data_quality")

    def tearDown(self):
        sys.modules.pop("pymssql", None)
        sys.modules.pop("boto3", None)

    def test_parse_db_connection_url(self):
        parsed = self.lambda_module.parse_db_connection_url(
            "jdbc:sqlserver://db.example.com:1433;databaseName=TENMAID_UAT;encrypt=true"
        )

        self.assertEqual(
            parsed,
            {
                "server": "db.example.com",
                "port": 1433,
                "database": "TENMAID_UAT",
            },
        )

    def test_lambda_handler_returns_success_when_no_findings(self):
        fake_pymssql = FakePymssql([])
        sys.modules["pymssql"] = fake_pymssql

        response = self.lambda_module.lambda_handler({}, Context())

        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(json.loads(response["body"])["results"][0]["Actual_Value"], 0)
        self.assertTrue(json.loads(response["body"])["results"][0]["passed"])
        self.assertEqual(fake_pymssql.connection_args["database"], "TENMAID_UAT")

    def test_lambda_handler_writes_error_file_when_findings_are_returned(self):
        fake_pymssql = FakePymssql([
            {
                "Error": "Required - Reference1 (Primary member reference) must not be null",
                "MemberID": 123,
                "Field": "Reference1",
                "Value": None,
            }
        ])
        sys.modules["pymssql"] = fake_pymssql

        response = self.lambda_module.lambda_handler({}, Context())

        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(json.loads(response["body"])["failed_rule_count"], 1)
        self.assertEqual(len(self.fake_boto3.s3.objects), 1)
        s3_object = self.fake_boto3.s3.objects[0]
        self.assertEqual(s3_object["Bucket"], "bi-qa.tenproduct.com")
        self.assertTrue(
            s3_object["Key"].startswith(
                "rpin-data-quality/errors/rpin-reference1-required/"
            )
        )
        self.assertEqual(
            s3_object["Body"].decode("utf-8").splitlines()[0],
            "table,check_name,expected_value,Actual_Value,created_timestamp",
        )
        self.assertIn("dbo.Members,rpin-reference1-required,0,1,", s3_object["Body"].decode("utf-8"))

    def test_lambda_handler_does_not_publish_db_connection_failure_metric(self):
        fake_pymssql = FakePymssql([], connect_error=ConnectionError("connection refused"))
        sys.modules["pymssql"] = fake_pymssql

        with self.assertRaisesRegex(RuntimeError, "Failed to connect"):
            self.lambda_module.lambda_handler({}, Context())

        self.assertEqual(self.fake_boto3.cloudwatch.metric_data, [])

    def test_expected_value_defaults_to_zero_when_blank(self):
        rule = self.lambda_module.normalize_rule(
            {
                "check_name": "rpin-reference1-required",
                "sql_check": "SELECT 1 AS finding",
                "table": "dbo.Members",
                "operator": "=",
                "expected_value": "",
            }
        )

        self.assertEqual(rule["expected_value"], 0)


if __name__ == "__main__":
    unittest.main()
