import importlib.util
import os
import sys
import types
import unittest
from pathlib import Path


def load_lambda_module():
    os.environ["BUCKET"] = "test-bucket"
    os.environ["ROOTS"] = "CA_BOA_Reports/incoming,ivector/incoming,mercuryhub/incoming"

    fake_boto3 = types.SimpleNamespace(client=lambda service_name: object())
    sys.modules["boto3"] = fake_boto3

    module_path = Path(__file__).resolve().parents[1] / "scripts" / "lambda_s3_rename.py"
    spec = importlib.util.spec_from_file_location("lambda_s3_rename", module_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


lambda_s3_rename = load_lambda_module()


class TestLambdaS3Rename(unittest.TestCase):
    def test_strip_trailing_non_letters_preserves_extension(self):
        cases = {
            "report_20260519.csv": "report.csv",
            "Partner File - 2026-05-19.txt": "Partner File.txt",
            "already-clean.csv": "already-clean.csv",
            "abc123": "abc",
            "reportv2.csv": "report.csv",
            "report_20260519v2.csv": "report.csv",
            "report_20260519_v2.csv": "report.csv",
            "filev.csv": "filev.csv",
            "12345.csv": "12345.csv",
        }

        for filename, expected in cases.items():
            with self.subTest(filename=filename):
                self.assertEqual(
                    lambda_s3_rename.strip_trailing_non_letters(filename),
                    expected,
                )

    def test_build_target_key_keeps_incoming_and_renames(self):
        self.assertEqual(
            lambda_s3_rename.build_target_key(
                "ivector/incoming/monthly_report_20260519v2.csv"
            ),
            "ivector/incoming/monthly_report.csv",
        )

    def test_build_target_key_preserves_subdirectory_within_incoming(self):
        self.assertEqual(
            lambda_s3_rename.build_target_key(
                "ivector/incoming/nested/path/monthly_report_20260519v2.csv"
            ),
            "ivector/incoming/nested/path/monthly_report.csv",
        )

    def test_build_target_key_supports_configured_roots(self):
        self.assertEqual(
            lambda_s3_rename.build_target_key("CA_BOA_Reports/incoming/report_001.csv"),
            "CA_BOA_Reports/incoming/report.csv",
        )
        self.assertEqual(
            lambda_s3_rename.build_target_key("mercuryhub/incoming/report_001.csv"),
            "mercuryhub/incoming/report.csv",
        )

    def test_build_target_key_rejects_unconfigured_root(self):
        with self.assertRaisesRegex(ValueError, "does not match any configured root"):
            lambda_s3_rename.build_target_key("other/incoming/report_001.csv")


if __name__ == "__main__":
    unittest.main()
