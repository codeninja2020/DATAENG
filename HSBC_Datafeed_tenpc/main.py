import csv
import datetime
import json
import logging
import os
import re
import sqlite3
import time
from collections import Counter
from itertools import islice
from pathlib import Path
from typing import Any, Dict, Iterable, List, Set, Tuple

import pandas as pd

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
LOGGER_NAME = "hsbc_datafeed_log"
logger = logging.getLogger(LOGGER_NAME)
logger.addHandler(logging.NullHandler())

CONFIG_PATH = Path(__file__).resolve().parent / "config.json"
DEFAULT_LOG_DIR = Path("logs")


def configure_logging(log_dir: Path = DEFAULT_LOG_DIR) -> Path:
    """
    Configure logging to both a run-specific log file and stdout.
    Returns the path to the log file created for this run.
    """
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / f"hsbc_process_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

    logger.setLevel(logging.INFO)
    logger.handlers.clear()
    logger.propagate = False

    formatter = logging.Formatter("%(asctime)s | %(levelname)s | %(message)s")

    file_handler = logging.FileHandler(log_file, encoding="utf-8")
    file_handler.setFormatter(formatter)

    stream_handler = logging.StreamHandler()
    stream_handler.setFormatter(formatter)

    logger.addHandler(file_handler)
    logger.addHandler(stream_handler)

    return log_file


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
DEFAULT_PRIMARY_PROGRAMME_REFERENCE = 2440
SQLITE_DB_PATH = Path("ten_standard_members.db")
SQLITE_TABLE_NAME = "ten_standard_members"


def load_json_config(config_path: Path) -> Dict[str, Any]:
    """Load dict from JSON config file; return empty dict on failure."""
    if not config_path.exists():
        logger.warning("%s not found. Using default settings.", config_path)
        return {}
    try:
        with config_path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as exc:  # noqa: BLE001
        logger.warning("Unable to read %s: %s. Using default settings.", config_path, exc)
        return {}


CONFIG = load_json_config(CONFIG_PATH)
PRIMARY_PROGRAMME_REFERENCE = (
    CONFIG.get("defaults", {}).get("primary_programme_reference", DEFAULT_PRIMARY_PROGRAMME_REFERENCE)
)

# ---------------------------------------------------------------------------
# Validation config import
# ---------------------------------------------------------------------------
try:
    from validation_config import MEMBER_DETAILS_VALIDATION, MINIMAL_VALIDATION

    def load_required_field_config(
        config_data: Dict[str, Any], base_rules: Dict[str, Dict[str, Any]]
    ) -> Dict[str, Dict[str, Any]]:
        """Override 'required' flags from config.json into the base validation rules."""
        updated_rules = {field: rules.copy() for field, rules in base_rules.items()}
        if not isinstance(config_data, dict):
            return updated_rules
        required_overrides = config_data.get("required_fields", {})
        if not isinstance(required_overrides, dict):
            logger.warning("'required_fields' in config must be an object. Using default validation rules.")
            return updated_rules
        for field, required_flag in required_overrides.items():
            if field not in updated_rules:
                logger.warning("Field '%s' in config not present in validation rules. Skipping.", field)
                continue
            required_bool = bool(required_flag)
            updated_rules[field]["required"] = required_bool
            if not required_bool:
                updated_rules[field]["not_null"] = False
        return updated_rules

    MANDATORY_FIELDS = load_required_field_config(CONFIG, MEMBER_DETAILS_VALIDATION)

except ImportError:
    logger.warning("validation_config.py not found. Using fallback validation rules.")
    MANDATORY_FIELDS = {
        "id": {"required": True, "not_null": True, "data_type": "int"},
        "email": {"required": True, "not_null": True, "data_type": "str", "min_length": 5},
        "first_name": {"required": True, "not_null": True, "data_type": "str", "min_length": 1},
        "last_name": {"required": True, "not_null": True, "data_type": "str", "min_length": 1},
        "address_line_1": {"required": True, "not_null": True, "data_type": "str"},
    }

FEED_MODE = str(CONFIG.get("feed_mode", "initial")).lower()
DEACTIVATION_STATUS_VALUE = str(CONFIG.get("deactivation_status_value", "INACTIVE")).upper()

MEMBER_STATUS_FIELD = "membership_status"
EMAIL_FIELD = "email_address"
PRIMARY_KEY_FIELD = "primary_member_reference"

file_path = "member_details.txt"
CHUNK_FILE_EXTENSION = ".txt"
CHUNK_OUTPUT_DIR = Path("chunks/")
DUPLICATE_KEY_FIELD = "CIN"

# ---------------------------------------------------------------------------
# Field mapping
# ---------------------------------------------------------------------------
TEN_STANDARD_FIELD_RENAMES: Dict[str, str] = {
    "CIN": "primary_member_reference",
    "Segment": "secondary_member_reference",
    "FirstName": "first_name",
    "Surname": "last_name",
    "Gender": "gender_code",
    "DOB": "date_of_birth",
    "DateOfBirth": "date_of_birth",
    "Membership_status": "membership_status",
    "Email": "email_address",
    "EmailAddress": "email_address",
    "Postcode": "post_code",
    "PostCode": "post_code",
}

TEN_STANDARD_DEFAULTS: Dict[str, Any] = {
    "primary_programme_reference": PRIMARY_PROGRAMME_REFERENCE,
}

TEN_STANDARD_CONFIG: Dict[str, Any] = CONFIG.get("ten_standard", {})
REVERSE_FIELD_RENAMES: Dict[str, List[str]] = {}
for source, target in TEN_STANDARD_FIELD_RENAMES.items():
    REVERSE_FIELD_RENAMES.setdefault(target, []).append(source)


# ---------------------------------------------------------------------------
# Mapping helpers
# ---------------------------------------------------------------------------
def map_chunk_to_ten_standard(chunk: pd.DataFrame) -> pd.DataFrame:
    """Map source member data to ten_standard column names."""
    mapped_chunk = chunk.rename(columns=TEN_STANDARD_FIELD_RENAMES).copy()
    mapped_chunk = mapped_chunk.loc[:, ~mapped_chunk.columns.duplicated()]

    if "primary_member_reference" not in mapped_chunk.columns:
        mapped_chunk["primary_member_reference"] = pd.NA
    if "secondary_programme_reference" not in mapped_chunk.columns:
        mapped_chunk["secondary_programme_reference"] = pd.NA

    if "primary_member_reference" in mapped_chunk.columns:
        mapped_chunk["primary_member_reference"] = mapped_chunk["primary_member_reference"].apply(
            lambda v: str(v).strip() if not pd.isna(v) else v
        )

    if MEMBER_STATUS_FIELD in mapped_chunk.columns:
        mapped_chunk[MEMBER_STATUS_FIELD] = mapped_chunk[MEMBER_STATUS_FIELD].apply(
            lambda v: str(v).strip().upper() if not pd.isna(v) else v
        )

    if EMAIL_FIELD in mapped_chunk.columns:
        mapped_chunk[EMAIL_FIELD] = mapped_chunk[EMAIL_FIELD].apply(
            lambda v: str(v).strip() if not pd.isna(v) else v
        )

    for target_field, default_value in TEN_STANDARD_DEFAULTS.items():
        mapped_chunk[target_field] = default_value

    return mapped_chunk


def align_to_ten_standard_columns(chunk: pd.DataFrame, ten_standard_config: Dict[str, Any]) -> pd.DataFrame:
    """Ensure chunk contains the configured ten_standard columns (NA if missing)."""
    if not ten_standard_config:
        return chunk

    aligned_chunk = chunk.copy()
    configured_columns = list(ten_standard_config.keys())

    for col in configured_columns:
        if col not in aligned_chunk.columns:
            aligned_chunk[col] = pd.NA

    extra_cols = [col for col in aligned_chunk.columns if col not in configured_columns]
    return aligned_chunk[configured_columns + extra_cols]


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
def chunked_iterable(iterable: Iterable[Any], size: int) -> Iterable[List[Any]]:
    """Yield successive batches from an iterable."""
    iterator = iter(iterable)
    while True:
        batch = list(islice(iterator, size))
        if not batch:
            break
        yield batch


def flag_true(value: Any) -> bool:
    """Interpret new_joiner flag strictly: only literal 1 or '1' is true."""
    if value is None:
        return False
    if isinstance(value, (int, float)) and value == 1:
        return True
    return str(value).strip() == "1"


def table_exists(conn: sqlite3.Connection, table_name: str) -> bool:
    """Check whether a SQLite table exists."""
    cursor = conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?", (table_name,)
    )
    return cursor.fetchone() is not None


def ensure_unique_index(conn: sqlite3.Connection, table_name: str, column_name: str) -> None:
    """Create a unique index on the given column. Safe to call repeatedly."""
    try:
        conn.execute(
            f'CREATE UNIQUE INDEX IF NOT EXISTS idx_{table_name}_{column_name} '
            f'ON {table_name}("{column_name}")'
        )
        conn.commit()
    except sqlite3.Error as exc:  # noqa: BLE001
        logger.warning("Unable to create unique index on %s.%s: %s", table_name, column_name, exc)


# ---------------------------------------------------------------------------
# FIX 1 + FIX 3 — email conflict detection (case-insensitive, keeps first)
# ---------------------------------------------------------------------------
def check_email_conflicts(chunk: pd.DataFrame, conn: sqlite3.Connection) -> Tuple[List[int], List[str]]:
    """
    Flag rows whose email already exists in the platform or duplicates within the feed.

    FIX 1: First occurrence of a duplicate email is kept; only subsequent rows are flagged.
    FIX 3: All email comparisons are case-insensitive (normalised to lowercase).

    Returns a tuple of (indices_to_exclude, error_messages).
    """
    conflict_indices: List[int] = []
    conflict_errors: List[str] = []

    if chunk.empty:
        return conflict_indices, conflict_errors

    candidate_email_columns = [EMAIL_FIELD, "Email", "EmailAddress", "email"]
    email_column = next((col for col in candidate_email_columns if col in chunk.columns), None)
    if not email_column:
        return conflict_indices, conflict_errors

    # FIX 3: normalise to lowercase before any comparison
    emails = chunk[email_column].dropna().astype(str).str.strip().str.lower()
    if emails.empty:
        return conflict_indices, conflict_errors

    # Build email -> list of indices map (order-preserving)
    email_to_indices: Dict[str, List[int]] = {}
    for idx, email in emails.items():
        if not email:
            continue
        email_to_indices.setdefault(email, []).append(idx)

    # FIX 1: keep first occurrence, flag only subsequent duplicates within chunk
    for email, indices in email_to_indices.items():
        if len(indices) > 1:
            first_idx = indices[0]
            for idx in indices[1:]:
                if idx not in conflict_indices:
                    conflict_indices.append(idx)
                    conflict_errors.append(
                        f"Row {idx}: Email '{email}' duplicated within feed file "
                        f"(first seen at row {first_idx})"
                    )

    # Check conflicts against existing platform rows (case-insensitive via LOWER())
    if table_exists(conn, SQLITE_TABLE_NAME):
        existing_conflicts: Set[str] = set()
        for batch in chunked_iterable(list(email_to_indices.keys()), 500):
            placeholders = ",".join("?" * len(batch))
            cursor = conn.execute(
                f"SELECT LOWER({EMAIL_FIELD}) FROM {SQLITE_TABLE_NAME} "
                f"WHERE LOWER({EMAIL_FIELD}) IN ({placeholders})",
                [e.lower() for e in batch],
            )
            existing_conflicts.update(row[0] for row in cursor.fetchall())

        for email in existing_conflicts:
            for idx in email_to_indices.get(email, []):
                if idx not in conflict_indices:
                    conflict_indices.append(idx)
                    conflict_errors.append(
                        f"Row {idx}: Email '{email}' already exists in "
                        f"'{SQLITE_TABLE_NAME}' - SSO login will fail"
                    )

    return conflict_indices, conflict_errors


# ---------------------------------------------------------------------------
# Incremental CIN check
# ---------------------------------------------------------------------------
def check_existing_cins(chunk: pd.DataFrame, conn: sqlite3.Connection) -> Tuple[List[int], List[str]]:
    """
    For incremental feeds, ensure 'new' members truly have a CIN not already in the platform.
    Returns indices to exclude and error messages.
    """
    conflict_indices: List[int] = []
    conflict_errors: List[str] = []

    if chunk.empty or DUPLICATE_KEY_FIELD not in chunk.columns:
        return conflict_indices, conflict_errors

    cins = chunk[DUPLICATE_KEY_FIELD].dropna().astype(str).str.strip()
    if cins.empty or not table_exists(conn, SQLITE_TABLE_NAME):
        return conflict_indices, conflict_errors

    cin_to_indices: Dict[str, List[int]] = {}
    for idx, cin in cins.items():
        if not cin:
            continue
        cin_to_indices.setdefault(cin, []).append(idx)

    existing_cins: Set[str] = set()
    for batch in chunked_iterable(list(cin_to_indices.keys()), 500):
        placeholders = ",".join("?" * len(batch))
        cursor = conn.execute(
            f'SELECT "{PRIMARY_KEY_FIELD}" FROM {SQLITE_TABLE_NAME} '
            f'WHERE "{PRIMARY_KEY_FIELD}" IN ({placeholders})',
            list(batch),
        )
        existing_cins.update(row[0] for row in cursor.fetchall())

    for cin in existing_cins:
        for idx in cin_to_indices.get(cin, []):
            conflict_indices.append(idx)
            conflict_errors.append(
                f"Row {idx}: CIN '{cin}' already exists in '{SQLITE_TABLE_NAME}' "
                f"- incremental adds must be new CINs"
            )

    return conflict_indices, conflict_errors


# ---------------------------------------------------------------------------
# Incremental processing
# ---------------------------------------------------------------------------
def split_incremental_sets(
    mapped_chunk: pd.DataFrame,
    status_field: str = MEMBER_STATUS_FIELD,
    deactivation_status: str = DEACTIVATION_STATUS_VALUE,
) -> Tuple[pd.DataFrame, pd.DataFrame]:
    """Split a chunk into active/new members and those to be deactivated."""
    if status_field not in mapped_chunk.columns:
        return mapped_chunk, pd.DataFrame(columns=mapped_chunk.columns)

    statuses = mapped_chunk[status_field].fillna("").astype(str).str.upper()
    deactivate_mask = statuses == deactivation_status.upper()
    return mapped_chunk.loc[~deactivate_mask], mapped_chunk.loc[deactivate_mask]


def upsert_sqlite(mapped_chunk: pd.DataFrame, conn: sqlite3.Connection) -> int:
    """Upsert records into SQLite using a staging table and ON CONFLICT strategy."""
    if mapped_chunk.empty:
        return 0

    ensure_unique_index(conn, SQLITE_TABLE_NAME, PRIMARY_KEY_FIELD)
    mapped_chunk.to_sql("_staging_upsert", conn, if_exists="replace", index=False)
    columns = list(mapped_chunk.columns)
    quoted_columns = ", ".join([f'"{col}"' for col in columns])
    update_assignments = ", ".join(
        [f'"{col}" = excluded."{col}"' for col in columns if col != PRIMARY_KEY_FIELD]
    )
    conn.execute(
        f"""
        INSERT INTO {SQLITE_TABLE_NAME} ({quoted_columns})
        SELECT {quoted_columns} FROM _staging_upsert
        ON CONFLICT("{PRIMARY_KEY_FIELD}") DO UPDATE SET
        {update_assignments}
        """
    )
    conn.commit()
    return len(mapped_chunk)


def process_incremental_chunk(mapped_chunk: pd.DataFrame, conn: sqlite3.Connection) -> Tuple[int, int]:
    """Handle daily incremental feed: upsert new/active members, mark deactivations."""
    if mapped_chunk.empty:
        return 0, 0

    if not table_exists(conn, SQLITE_TABLE_NAME):
        mapped_chunk.to_sql(SQLITE_TABLE_NAME, conn, if_exists="replace", index=False)
        ensure_unique_index(conn, SQLITE_TABLE_NAME, PRIMARY_KEY_FIELD)
        conn.commit()
        return len(mapped_chunk), 0

    new_members, deactivated = split_incremental_sets(
        mapped_chunk, status_field=MEMBER_STATUS_FIELD, deactivation_status=DEACTIVATION_STATUS_VALUE
    )

    upserted = upsert_sqlite(new_members, conn) if not new_members.empty else 0

    deactivated_count = 0
    if not deactivated.empty and PRIMARY_KEY_FIELD in deactivated.columns:
        cins = deactivated[PRIMARY_KEY_FIELD].dropna().astype(str).tolist()
        if cins:
            placeholders = ",".join("?" * len(cins))
            conn.execute(
                f'UPDATE {SQLITE_TABLE_NAME} SET {MEMBER_STATUS_FIELD} = ? '
                f'WHERE {PRIMARY_KEY_FIELD} IN ({placeholders})',
                [DEACTIVATION_STATUS_VALUE] + cins,
            )
            conn.commit()
            deactivated_count = len(cins)

    return upserted, deactivated_count


# ---------------------------------------------------------------------------
# QA reporting
# ---------------------------------------------------------------------------
def _extract_field_from_error(error: str) -> str:
    """Best-effort extraction of the field referenced in an error message."""
    match = re.search(r"Field '([^']+)'", error)
    if match:
        return match.group(1)
    if "Duplicate" in error:
        return "duplicate"
    if "Email" in error or "email" in error:
        return EMAIL_FIELD
    return "other"


def generate_qa_report(
    all_errors: List[str], total_valid: int, total_invalid: int, output_path: Path
) -> None:
    """Generate a client-facing QA summary JSON."""
    total_records = total_valid + total_invalid
    pass_rate = round((total_valid / total_records) * 100, 2) if total_records else 0.0
    error_counts = Counter(_extract_field_from_error(err) for err in all_errors)

    report = {
        "generated_at": datetime.datetime.now().isoformat(),
        "summary": {
            "total_records": total_records,
            "passed": total_valid,
            "failed": total_invalid,
            "pass_rate_pct": pass_rate,
        },
        "errors_by_field": dict(error_counts),
        "checks_performed": [
            "Required field presence",
            "Null/empty field check",
            "Email format validation",
            "Duplicate CIN detection",
            "Email conflict with existing platform users",
            "Postcode format/length check (flag only — international rows retained)",
        ],
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    logger.info("QA report saved to %s", output_path)


# ---------------------------------------------------------------------------
# Row / chunk validation
# ---------------------------------------------------------------------------
def validate_row(
    row: pd.Series, row_index: int, validation_rules: Dict
) -> Tuple[bool, List[str]]:
    """Validate a single row against mandatory field requirements."""
    errors = []

    for field, rules in validation_rules.items():
        value = None

        if field in row.index:
            value = row.get(field)
        else:
            aliases = [
                alias for alias in REVERSE_FIELD_RENAMES.get(field, []) if alias in row.index
            ]
            if aliases:
                value = row.get(aliases[0])
            elif rules.get("required", False):
                errors.append(f"Row {row_index}: Missing required field '{field}'")
                continue

        if rules.get("not_null", False):
            if pd.isna(value) or value == "" or (isinstance(value, str) and value.strip() == ""):
                errors.append(f"Row {row_index}: Field '{field}' cannot be null/empty")
                continue

        if pd.isna(value) or value == "":
            continue

        data_type = rules.get("data_type")
        if data_type == "int":
            try:
                int(value)
            except (ValueError, TypeError):
                errors.append(f"Row {row_index}: Field '{field}' must be integer, got '{value}'")

        elif data_type == "float":
            try:
                float(value)
            except (ValueError, TypeError):
                errors.append(f"Row {row_index}: Field '{field}' must be numeric, got '{value}'")

        elif data_type == "date":
            if not pd.api.types.is_datetime64_any_dtype(type(value)):
                try:
                    pd.to_datetime(value)
                except Exception:
                    errors.append(
                        f"Row {row_index}: Field '{field}' must be valid date, got '{value}'"
                    )

        if data_type == "str" and isinstance(value, str):
            min_length = rules.get("min_length")
            if min_length and len(value.strip()) < min_length:
                errors.append(
                    f"Row {row_index}: Field '{field}' must be at least {min_length} characters"
                )
            max_length = rules.get("max_length")
            if max_length and len(value) > max_length:
                errors.append(
                    f"Row {row_index}: Field '{field}' exceeds max length {max_length}"
                )

        custom_validator = rules.get("custom_validator")
        if custom_validator and callable(custom_validator):
            if not custom_validator(value):
                errors.append(f"Row {row_index}: Field '{field}' failed custom validation")

    return len(errors) == 0, errors


def validate_chunk(
    chunk: pd.DataFrame, validation_rules: Dict, chunk_number: int
) -> Dict[str, Any]:
    """Validate all rows in a chunk; return statistics and per-row errors."""
    results: Dict[str, Any] = {
        "chunk_number": chunk_number,
        "total_rows": len(chunk),
        "valid_rows": 0,
        "invalid_rows": 0,
        "errors": [],
        "valid_indices": [],
        "invalid_indices": [],
    }

    for idx, row in chunk.iterrows():
        is_valid, errors = validate_row(row, idx, validation_rules)
        if is_valid:
            results["valid_rows"] += 1
            results["valid_indices"].append(idx)
        else:
            results["invalid_rows"] += 1
            results["invalid_indices"].append(idx)
            results["errors"].extend(errors)

    return results


# ---------------------------------------------------------------------------
# Misc helpers
# ---------------------------------------------------------------------------
def read_txt_with_delimiter(filename: str, delimiter: str) -> List[List[str]]:
    data = []
    with open(filename, "r", newline="", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter=delimiter)
        for row in reader:
            data.append(row)
    return data


def detect_duplicates_on_key(
    chunk: pd.DataFrame, key_column: str, seen_keys: Set[str]
) -> Tuple[List[int], List[str]]:
    """
    Identify duplicate rows based on a key column across chunks.
    First occurrence is kept; subsequent occurrences are flagged.
    """
    duplicate_indices: List[int] = []
    duplicate_errors: List[str] = []

    if chunk.empty or key_column not in chunk.columns:
        return duplicate_indices, duplicate_errors

    current_chunk_keys: Set[str] = set()

    for idx, value in chunk[key_column].items():
        if pd.isna(value):
            continue
        key = str(value).strip()
        if key in seen_keys or key in current_chunk_keys:
            duplicate_indices.append(idx)
            duplicate_errors.append(f"Row {idx}: Duplicate {key_column} value '{key}'")
        else:
            current_chunk_keys.add(key)

    seen_keys.update(current_chunk_keys)
    return duplicate_indices, duplicate_errors


# ---------------------------------------------------------------------------
# FIX 2 — wrangle_chunk: capture dropped rows + postcode flags not drops
# ---------------------------------------------------------------------------
def wrangle_chunk(
    chunk: pd.DataFrame, required_fields: Dict[str, bool]
) -> Tuple[pd.DataFrame, Dict[str, int], pd.DataFrame]:
    """
    Perform data wrangling on chunk:
      1. Drop rows with NA/null in mandatory fields  → captured in wrangled_out
      2. Drop rows with invalid email format         → captured in wrangled_out
      3. FLAG rows with non-UK postcodes (not drop)  → logged as warning, row retained

    FIX 2a: Returns wrangled_out DataFrame so callers can write these rows to the
             error file with a reason column instead of silently discarding them.
    FIX 2b: Postcode check no longer drops rows — international members are retained.

    Returns:
        cleaned_df      — rows that passed wrangling
        stats           — counts by drop reason
        wrangled_out    — rows removed during wrangling, with 'validation_errors' column
    """
    stats = {
        "dropped_na_mandatory": 0,
        "dropped_invalid_email": 0,
        "flagged_invalid_postcode": 0,   # renamed: no longer dropped
        "total_dropped": 0,
    }

    if chunk.empty:
        empty_with_col = chunk.copy()
        if "validation_errors" not in empty_with_col.columns:
            empty_with_col["validation_errors"] = pd.NA
        return chunk, stats, empty_with_col

    cleaned_df = chunk.copy()
    original_row_count = len(cleaned_df)
    dropped_frames: List[pd.DataFrame] = []

    #  Drop NA values for mandatory fields
    mandatory_cols = [
        col
        for col, is_required in required_fields.items()
        if is_required and col in cleaned_df.columns
    ]

    if mandatory_cols:
        na_mask = cleaned_df[mandatory_cols].isna().any(axis=1)
        dropped_na = cleaned_df[na_mask].copy()
        if not dropped_na.empty:
            dropped_na["validation_errors"] = (
                "Dropped: NA value in mandatory field(s): "
                + dropped_na[mandatory_cols]
                .isna()
                .apply(
                    lambda row: ", ".join([col for col, is_na in row.items() if is_na]),
                    axis=1,
                )
            )
            dropped_frames.append(dropped_na)
            stats["dropped_na_mandatory"] = len(dropped_na)
            logger.info(
                "Dropped %s rows with NA values in mandatory fields: %s",
                len(dropped_na),
                mandatory_cols,
            )
        cleaned_df = cleaned_df[~na_mask]

    #  Drop rows with invalid email addresses
    email_col_wrangle = next(
        (c for c in ["email_address", "Email", "EmailAddress", "email"] if c in cleaned_df.columns),
        None,
    )
    if email_col_wrangle:
        email_regex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        valid_email_mask = (
            cleaned_df[email_col_wrangle].astype(str).str.match(email_regex, na=False)
        )
        dropped_email = cleaned_df[~valid_email_mask].copy()
        if not dropped_email.empty:
            dropped_email["validation_errors"] = (
                "Dropped: Invalid email address format: "
                + dropped_email[email_col_wrangle].astype(str)
            )
            dropped_frames.append(dropped_email)
            stats["dropped_invalid_email"] = len(dropped_email)
            logger.info("Dropped %s rows with invalid email addresses", len(dropped_email))
        cleaned_df = cleaned_df[valid_email_mask]

    # ------------------------------------------------------------------
    # Step 3 (FIX 2b): Flag non-UK postcodes — log warning, DO NOT drop
    # International members (HK, FR, LT, BN, AU, MY …) must be retained.
    # ------------------------------------------------------------------
    postcode_col = next(
        (c for c in ["post_code", "PostCode", "Postcode"] if c in cleaned_df.columns), None
    )
    if postcode_col:
        uk_postcode_regex = r"^[A-Z]{1,2}\d{1,2}[A-Z]?\s*\d[A-Z]{2}$"
        non_uk_mask = ~cleaned_df[postcode_col].astype(str).str.match(
            uk_postcode_regex, na=False
        )
        flagged_count = int(non_uk_mask.sum())
        stats["flagged_invalid_postcode"] = flagged_count
        if flagged_count > 0:
            logger.info(
                "Flagged %s rows with non-UK/unrecognised postcodes "
                "(rows retained — international members included)",
                flagged_count,
            )

    # ------------------------------------------------------------------
    # Compile wrangled_out
    # ------------------------------------------------------------------
    wrangled_out = (
        pd.concat(dropped_frames, ignore_index=False)
        if dropped_frames
        else pd.DataFrame(columns=list(chunk.columns) + ["validation_errors"])
    )

    stats["total_dropped"] = original_row_count - len(cleaned_df)

    if stats["total_dropped"] > 0:
        logger.info(
            "Total rows dropped during wrangling: %s out of %s (%.2f%%)",
            stats["total_dropped"],
            original_row_count,
            (stats["total_dropped"] / original_row_count * 100) if original_row_count > 0 else 0,
        )

    return cleaned_df, stats, wrangled_out


# ---------------------------------------------------------------------------
# Error file writer (shared by wrangled-out and validation-failed rows)
# ---------------------------------------------------------------------------
def write_error_file(
    invalid_chunk: pd.DataFrame,
    validation_errors: List[str],
    wrangled_out: pd.DataFrame,
    chunk_index: int,
) -> None:
    """
    Build and write the per-chunk error file.

    Combines:
      - rows that failed validation / email-conflict / duplicate checks
        (with reasons extracted from validation_errors list)
      - rows dropped during wrangling (already carry 'validation_errors' column)
    """
    CHUNK_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    error_file = CHUNK_OUTPUT_DIR / f"member_details_errors_chunk_{chunk_index}{CHUNK_FILE_EXTENSION}"

    frames_to_write: List[pd.DataFrame] = []

    # -- Validation-failed rows ------------------------------------------
    if not invalid_chunk.empty:
        invalid_with_errors = invalid_chunk.copy()

        # Build index -> [reason, …] map from the error strings
        error_map: Dict[int, List[str]] = {}
        for error in validation_errors:
            match = re.match(r"Row (\d+):", error)
            if match:
                row_num = int(match.group(1))
                error_map.setdefault(row_num, []).append(
                    error.split(": ", 1)[1] if ": " in error else error
                )

        if "validation_errors" not in invalid_with_errors.columns:
            invalid_with_errors["validation_errors"] = invalid_with_errors.index.map(
                lambda idx: " | ".join(error_map.get(idx, ["Unknown error"]))
            )

        frames_to_write.append(invalid_with_errors)

    # -- Wrangling-dropped rows ------------------------------------------
    if not wrangled_out.empty:
        frames_to_write.append(wrangled_out)

    if not frames_to_write:
        return

    combined = pd.concat(frames_to_write, ignore_index=False)
    combined.to_csv(error_file, sep="|", index=False)
    logger.info(
        "Error file saved to %s (%s rows — validation failures + wrangling drops)",
        error_file,
        len(combined),
    )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    log_file = configure_logging()
    logger.info("%s", "=" * 60)
    logger.info("Starting validation at %s", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    logger.info("Logging to %s", log_file)
    logger.info("%s", "=" * 60)

    script_start_time = time.time()

    if not os.path.exists(file_path):
        logger.error("%s not found. Create sample file first.", file_path)
        raise SystemExit(1)

    CHUNK_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    df_iterator = pd.read_csv(
        file_path, sep="|", engine="python", encoding="utf-8", chunksize=1_000_000
    )

    total_valid = 0
    total_invalid = 0
    total_email_conflicts = 0
    all_errors: List[str] = []
    conn = sqlite3.connect(SQLITE_DB_PATH)
    table_initialized = False
    seen_duplicate_keys: Set[str] = set()

    try:
        for i, chunk in enumerate(df_iterator):
            chunk_start_time = time.time()

            logger.info("%s", "=" * 60)
            logger.info("Processing chunk %s, shape: %s", i + 1, chunk.shape)
            logger.info("%s", "=" * 60)

            # ----------------------------------------------------------------
            # Wrangling — FIX 2: now returns wrangled_out for error reporting
            # ----------------------------------------------------------------
            required_fields_dict = CONFIG.get("required_fields", {})
            chunk, wrangling_stats, wrangled_out = wrangle_chunk(chunk, required_fields_dict)

            if not wrangled_out.empty:
                logger.info(
                    "Chunk %s: %s rows removed during wrangling (will appear in error file)",
                    i + 1,
                    len(wrangled_out),
                )

            if chunk.empty:
                logger.warning("Chunk %s is empty after wrangling. Skipping.", i + 1)
                # Still write the wrangling drops to the error file
                if not wrangled_out.empty:
                    write_error_file(pd.DataFrame(), [], wrangled_out, i + 1)
                continue

            # ----------------------------------------------------------------
            # Validation
            # ----------------------------------------------------------------
            validation_results = validate_chunk(chunk, MANDATORY_FIELDS, i + 1)

            valid_chunk = chunk.loc[validation_results["valid_indices"]]
            invalid_chunk = chunk.loc[validation_results["invalid_indices"]]

            # ----------------------------------------------------------------
            # Duplicate CIN detection
            # ----------------------------------------------------------------
            duplicate_indices, duplicate_errors = detect_duplicates_on_key(
                valid_chunk, DUPLICATE_KEY_FIELD, seen_duplicate_keys
            )

            if duplicate_indices:
                duplicate_rows = valid_chunk.loc[duplicate_indices]
                valid_chunk = valid_chunk.drop(index=duplicate_indices)
                invalid_chunk = pd.concat([invalid_chunk, duplicate_rows])
                validation_results["errors"].extend(duplicate_errors)
                validation_results["valid_indices"] = valid_chunk.index.tolist()
                validation_results["invalid_indices"] = invalid_chunk.index.tolist()
                validation_results["valid_rows"] = len(valid_chunk)
                validation_results["invalid_rows"] = len(invalid_chunk)

            # ----------------------------------------------------------------
            # Email conflict detection — FIX 1 + FIX 3 applied inside function
            # ----------------------------------------------------------------
            email_conflict_indices, email_conflict_errors = check_email_conflicts(
                valid_chunk, conn
            )

            if email_conflict_indices:
                conflict_rows = valid_chunk.loc[email_conflict_indices]
                valid_chunk = valid_chunk.drop(index=email_conflict_indices)
                invalid_chunk = pd.concat([invalid_chunk, conflict_rows])
                total_email_conflicts += len(email_conflict_indices)

                logger.info(
                    "Email conflicts detected in chunk %s: %s", i + 1, len(email_conflict_indices)
                )

                validation_results["errors"].extend(email_conflict_errors)
                validation_results["valid_indices"] = valid_chunk.index.tolist()
                validation_results["invalid_indices"] = invalid_chunk.index.tolist()
                validation_results["valid_rows"] = len(valid_chunk)
                validation_results["invalid_rows"] = len(invalid_chunk)

            # ----------------------------------------------------------------
            # Incremental: reject CINs already in platform
            # ----------------------------------------------------------------
            if FEED_MODE == "incremental":
                existing_cin_indices, existing_cin_errors = check_existing_cins(
                    valid_chunk, conn
                )
                if existing_cin_indices:
                    conflict_rows = valid_chunk.loc[existing_cin_indices]
                    valid_chunk = valid_chunk.drop(index=existing_cin_indices)
                    invalid_chunk = pd.concat([invalid_chunk, conflict_rows])
                    validation_results["errors"].extend(existing_cin_errors)
                    validation_results["valid_indices"] = valid_chunk.index.tolist()
                    validation_results["invalid_indices"] = invalid_chunk.index.tolist()
                    validation_results["valid_rows"] = len(valid_chunk)
                    validation_results["invalid_rows"] = len(invalid_chunk)

            # ----------------------------------------------------------------
            # Log summary for chunk
            # ----------------------------------------------------------------
            logger.info("Valid rows: %s", validation_results["valid_rows"])
            logger.info("Invalid rows: %s", validation_results["invalid_rows"])

            if validation_results["errors"]:
                logger.info("Validation Errors (showing first 10):")
                for error in validation_results["errors"][:10]:
                    logger.info("  - %s", error)
                remaining = len(validation_results["errors"]) - 10
                if remaining > 0:
                    logger.info("  ... and %s more errors", remaining)

            # ----------------------------------------------------------------
            # Load valid rows into SQLite
            # ----------------------------------------------------------------
            if not valid_chunk.empty:
                mapped_valid_chunk = map_chunk_to_ten_standard(valid_chunk)
                mapped_valid_chunk = align_to_ten_standard_columns(
                    mapped_valid_chunk, TEN_STANDARD_CONFIG
                )
                if FEED_MODE == "incremental":
                    upserted_count, deactivated_count = process_incremental_chunk(
                        mapped_valid_chunk, conn
                    )
                    table_initialized = True
                    logger.info(
                        "✓ Incremental load applied (%s upserts, %s deactivations)",
                        upserted_count,
                        deactivated_count,
                    )
                else:
                    if_exists_option = "replace" if not table_initialized else "append"
                    mapped_valid_chunk.to_sql(
                        SQLITE_TABLE_NAME, conn, if_exists=if_exists_option, index=False
                    )
                    table_initialized = True
                    ensure_unique_index(conn, SQLITE_TABLE_NAME, PRIMARY_KEY_FIELD)
                    logger.info(
                        "✓ %s valid rows loaded into SQLite table '%s'",
                        len(valid_chunk),
                        SQLITE_TABLE_NAME,
                    )

            # ----------------------------------------------------------------
            # Write error file — FIX 2: includes wrangling-dropped rows
            # ----------------------------------------------------------------
            write_error_file(
                invalid_chunk,
                validation_results["errors"],
                wrangled_out,
                i + 1,
            )

            total_valid += validation_results["valid_rows"]
            total_invalid += validation_results["invalid_rows"]
            all_errors.extend(validation_results["errors"])

            chunk_elapsed = time.time() - chunk_start_time
            rows_per_second = (
                f"{len(chunk) / chunk_elapsed:.0f}" if chunk_elapsed > 0 else "n/a"
            )
            logger.info(
                "Chunk %s processing time: %.2f seconds (%s rows/sec)",
                i + 1,
                chunk_elapsed,
                rows_per_second,
            )

    finally:
        conn.close()

    # -----------------------------------------------------------------------
    # Final summary
    # -----------------------------------------------------------------------
    script_elapsed_time = time.time() - script_start_time

    logger.info("%s", "=" * 60)
    logger.info("VALIDATION SUMMARY")
    logger.info("%s", "=" * 60)
    logger.info("Total valid rows: %s", total_valid)
    logger.info("Total invalid rows: %s", total_invalid)
    total_processed = total_valid + total_invalid
    if total_processed > 0:
        logger.info("Success rate: %.2f%%", total_valid / total_processed * 100)
    else:
        logger.info("Success rate: N/A")
    logger.info("Total email conflicts flagged: %s", total_email_conflicts)

    if all_errors:
        logger.info("Total errors: %s", len(all_errors))
        error_log = f'validation_errors_{datetime.datetime.now().strftime("%Y%m%d_%H%M%S")}.log'
        with open(error_log, "w", encoding="utf-8") as f:
            f.write("\n".join(all_errors))
        logger.info("Complete error log saved to %s", error_log)

    qa_report_path = DEFAULT_LOG_DIR / "hsbc_qa_report.json"
    generate_qa_report(all_errors, total_valid, total_invalid, qa_report_path)

    total_rows = total_valid + total_invalid
    logger.info("%s", "=" * 60)
    logger.info("PERFORMANCE METRICS")
    logger.info("%s", "=" * 60)
    logger.info(
        "Total processing time: %.2f seconds (%.2f minutes)",
        script_elapsed_time,
        script_elapsed_time / 60,
    )
    logger.info("Total rows processed: %s", f"{total_rows:,}")
    if script_elapsed_time > 0 and total_rows > 0:
        logger.info(
            "Processing speed: %s rows/second", f"{total_rows / script_elapsed_time:.0f}"
        )
        logger.info(
            "Average time per row: %.2f milliseconds",
            (script_elapsed_time / total_rows) * 1000,
        )
    else:
        logger.info("Processing speed: N/A")
        logger.info("Average time per row: N/A")

    logger.info("Completed at: %s", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    if table_initialized:
        logger.info(
            "SQLite database created at %s with table '%s'", SQLITE_DB_PATH, SQLITE_TABLE_NAME
        )
    else:
        logger.info("No valid rows were loaded into SQLite.")
    logger.info("%s", "=" * 60)
    logger.info("Process log saved to %s", log_file)