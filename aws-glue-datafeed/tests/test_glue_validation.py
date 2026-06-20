import ast
import csv
import re
import unittest
from collections import deque
from pathlib import Path


SCRIPTS_DIR = Path(__file__).resolve().parents[1] / "scripts"
EXAMPLE_PATH = Path(__file__).resolve().parents[1] / "member_datafeed_example.csv"

_SCRIPT_FILES = [
    SCRIPTS_DIR / "validation.py",
    SCRIPTS_DIR / "load.py",
    SCRIPTS_DIR / "glue_mssql_etl.py",
]


def load_constant(name):
    for path in _SCRIPT_FILES:
        tree = ast.parse(path.read_text(encoding="utf-8"))
        for node in tree.body:
            if isinstance(node, ast.Assign):
                for target in node.targets:
                    if isinstance(target, ast.Name) and target.id == name:
                        return ast.literal_eval(node.value)
            if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
                if node.target.id == name:
                    return ast.literal_eval(node.value)
    raise AssertionError(f"Constant {name} not found in any script file")


class GlueValidationConfigTests(unittest.TestCase):
    def setUp(self):
        self.email_regex = re.compile(load_constant("EMAIL_REGEX"))
        self.cin_regex = re.compile(load_constant("CIN_REGEX"))
        self.e164_phone_regex = re.compile(load_constant("E164_PHONE_REGEX"))
        self.uk_postcode_regex = re.compile(load_constant("UK_POSTCODE_REGEX"))
        self.country_code_regex = re.compile(load_constant("COUNTRY_CODE_REGEX"))
        self.iso_country_codes = load_constant("ISO_COUNTRY_CODES")
        self.required_columns = load_constant("REQUIRED_COLUMNS")
        self.field_renames = load_constant("FIELD_RENAMES")
        self.max_lengths = load_constant("MAX_LENGTHS")
        self.members_column_mapping = load_constant("MEMBERS_COLUMN_MAPPING")
        self.jdbc_secret_arn_env = load_constant("JDBC_SECRET_ARN_ENV")
        self.private_bank_scheme_id_env = load_constant("PRIVATE_BANK_SCHEME_ID_ENV")
        self.premier_scheme_id_env = load_constant("PREMIER_SCHEME_ID_ENV")

    def test_accepts_numeric_and_prefixed_cins(self):
        self.assertRegex("1457546183", self.cin_regex)
        self.assertRegex("G1651798125", self.cin_regex)

    def test_rejects_invalid_cins(self):
        self.assertNotRegex("G165179812", self.cin_regex)
        self.assertNotRegex("A1651798125", self.cin_regex)
        self.assertNotRegex("14575461830", self.cin_regex)

    def test_accepts_valid_email_addresses(self):
        self.assertRegex("laurence.hubbard@example.com", self.email_regex)
        self.assertRegex("first.last+tag@example.co.uk", self.email_regex)
        self.assertRegex("name@example", self.email_regex)

    def test_rejects_invalid_email_addresses(self):
        self.assertNotRegex("missing-at-symbol.example.com", self.email_regex)
        self.assertNotRegex("@example.com", self.email_regex)
        self.assertNotRegex("name@-example.com", self.email_regex)

    def test_new_feed_columns_map_to_ten_standard_columns(self):
        self.assertEqual(self.field_renames["CIN"], "primary_member_reference")
        self.assertEqual(self.field_renames["segment"], "secondary_member_reference")
        self.assertEqual(self.field_renames["scheme_name"], "primary_programme_reference")
        self.assertEqual(self.field_renames["membership_status"], "membership_status")

    def test_accepts_valid_country_codes_and_e164_phone_numbers(self):
        self.assertRegex("GB", self.country_code_regex)
        self.assertRegex("+447700900123", self.e164_phone_regex)
        self.assertIn("GB", self.iso_country_codes)
        self.assertRegex("SW1A 1AA", self.uk_postcode_regex)

    def test_rejects_invalid_country_codes_and_phone_numbers(self):
        self.assertNotRegex("GBR", self.country_code_regex)
        self.assertNotRegex("+44 7700 900123", self.e164_phone_regex)
        self.assertNotRegex("07700900123", self.e164_phone_regex)
        self.assertNotRegex("+44123", self.e164_phone_regex)
        self.assertNotRegex("INVALID", self.uk_postcode_regex)

    def test_feed_length_limits_are_configured(self):
        self.assertEqual(self.max_lengths["primary_programme_reference"], 11)
        self.assertEqual(self.max_lengths["first_name"], 100)
        self.assertEqual(self.max_lengths["email_address"], 100)

    def test_jdbc_credentials_use_secret_arn_environment_variable(self):
        self.assertEqual(self.jdbc_secret_arn_env, "JDBC_SECRET_ARN")

    def test_scheme_ids_use_glue_customer_environment_variables(self):
        self.assertEqual(self.private_bank_scheme_id_env, "CUSTOMER_PRIVATE_BANK_SCHEME_ID")
        self.assertEqual(self.premier_scheme_id_env, "CUSTOMER_PREMIER_SCHEME_ID")

    def test_tenmaid_members_column_mapping(self):
        self.assertEqual(self.members_column_mapping["Reference1"], "primary_member_reference")
        self.assertEqual(self.members_column_mapping["Reference2"], "secondary_member_reference")
        self.assertEqual(self.members_column_mapping["Reference3"], "primary_programme_reference")
        self.assertEqual(self.members_column_mapping["PrimaryEmail"], "email_address")
        self.assertEqual(self.members_column_mapping["PrimaryMobile"], "main_phone")
        self.assertNotIn("SchemeID", self.members_column_mapping)
        self.assertNotIn("MemberID", self.members_column_mapping)

    def test_included_example_contains_valid_and_invalid_feed_rows(self):
        with EXAMPLE_PATH.open(newline="", encoding="utf-8") as example:
            reader = csv.DictReader(example)
            valid_rows = []
            invalid_rows = deque(maxlen=10)
            row_count = 0

            for row_count, row in enumerate(reader, start=1):
                if row_count <= 10:
                    valid_rows.append(row)
                invalid_rows.append(row)

        self.assertEqual(row_count, 1_000_000)
        self.assertEqual(len(valid_rows), 10)
        self.assertEqual(len(invalid_rows), 10)
        invalid_rows = list(invalid_rows)

        for row in valid_rows:
            self.assertRegex(row["CIN"], self.cin_regex)
            self.assertRegex(row["country_code"], self.country_code_regex)
            self.assertRegex(row["email_address"], self.email_regex)
            self.assertRegex(row["main_phone"], self.e164_phone_regex)
            for phone_column in ["business_phone", "home_phone"]:
                if row[phone_column]:
                    self.assertRegex(row[phone_column], self.e164_phone_regex)

        self.assertNotRegex(invalid_rows[0]["CIN"], self.cin_regex)
        self.assertNotRegex(invalid_rows[1]["CIN"], self.cin_regex)
        self.assertNotIn(invalid_rows[2]["scheme_name"], ["PrivateBank", "Premier"])
        self.assertNotIn(invalid_rows[3]["membership_status"], ["0", "1"])
        self.assertFalse(invalid_rows[4]["title_code"].isdigit())
        self.assertNotIn(invalid_rows[5]["gender_code"], ["0", "1", "2", "3", "4"])
        self.assertNotRegex(invalid_rows[6]["email_address"], self.email_regex)
        self.assertNotRegex(invalid_rows[7]["post_code"], self.uk_postcode_regex)
        self.assertNotIn(invalid_rows[8]["country_code"], self.iso_country_codes)
        self.assertNotRegex(invalid_rows[9]["main_phone"], self.e164_phone_regex)

    def test_required_member_fields_are_enforced(self):
        self.assertEqual(
            self.required_columns,
            [
                "primary_member_reference",
                "secondary_member_reference",
                "primary_programme_reference",
                "membership_status",
                "title_code",
                "first_name",
                "last_name",
                "gender_code",
                "language_code",
                "date_of_birth",
                "address_line_1",
                "address_line_2",
                "town_city",
                "state_region",
                "post_code",
                "country_code",
                "email_address",
                "main_phone",
            ],
        )


if __name__ == "__main__":
    unittest.main()
