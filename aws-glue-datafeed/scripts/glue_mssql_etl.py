"""Chunked Pandas ETL for validating HSBC member feeds and upserting SQL Server."""

import json
import hashlib
import io
import os
import re
import sys
import traceback
from datetime import date, datetime, time
from typing import Dict, Iterator, List, Tuple
from urllib.parse import unquote, urlparse

import boto3
import pandas as pd
import pymssql
from awsglue.utils import getResolvedOptions
from botocore.exceptions import ClientError

from load import (
    build_members_model_pandas,
    filter_changed_pandas,
)
from validation import (
    reject_email_conflicts_pandas,
    split_valid_invalid_pandas,
    with_validation_errors_pandas,
)

FIELD_RENAMES: Dict[str, str] = {
    "CIN": "primary_member_reference",
    "Segment": "secondary_member_reference",
    "segment": "secondary_member_reference",
    "scheme_name": "primary_programme_reference",
    "FirstName": "first_name",
    "Surname": "last_name",
    "Gender": "gender_code",
    "DOB": "date_of_birth",
    "DateOfBirth": "date_of_birth",
    "Membership_status": "membership_status",
    "MembershipStatus": "membership_status",
    "membership_status": "membership_status",
    "Email": "email_address",
    "EmailAddress": "email_address",
    "Postcode": "post_code",
    "PostCode": "post_code",
}

TEN_STANDARD_COLUMNS: List[str] = [
    "primary_member_reference",
    "secondary_member_reference",
    "primary_programme_reference",
    "secondary_programme_reference",
    "account_type",
    "parent_member_primary_reference",
    "parent_member_relationship_code",
    "membership_status",
    "membership_start_date",
    "membership_end_date",
    "title_code",
    "first_name",
    "middle_name",
    "last_name",
    "gender_code",
    "language_code",
    "date_of_birth",
    "street_number",
    "address_line_1",
    "address_line_2",
    "post_code",
    "town_city",
    "state_region",
    "country_code",
    "business_phone",
    "home_phone",
    "main_phone",
    "email_address",
    "file_name",
    "non_standard_fields",
]

STAGING_COLUMNS = TEN_STANDARD_COLUMNS + ["scheme_id"]

JDBC_SECRET_ARN_ENV = "JDBC_SECRET_ARN"
PRIVATE_BANK_SCHEME_ID_ENV = "CUSTOMER_PRIVATE_BANK_SCHEME_ID"
PREMIER_SCHEME_ID_ENV = "CUSTOMER_PREMIER_SCHEME_ID"
PANDAS_CHUNK_SIZE = 100000
SQL_BATCH_SIZE = 100000
STAGING_TABLE = "#members_staging"


def parse_args() -> Dict[str, str]:
    return getResolvedOptions(
        sys.argv,
        [
            "JOB_NAME",
            "SOURCE_S3_PATH",
            "ERROR_S3_PATH",
            "ARCHIVE_S3_PATH",
            "CHECKPOINT_S3_PATH",
            "JDBC_URL",
            "JDBC_SECRET_ARN",
            "TARGET_TABLE",
            "INPUT_DELIMITER",
        ],
    )


def get_jdbc_credentials() -> Dict[str, str]:
    # Load database credentials without logging any secret values.
    print("[Step 2] Loading SQL Server credentials from Secrets Manager")
    secret_arn = os.environ.get(JDBC_SECRET_ARN_ENV)
    if not secret_arn:
        raise ValueError(f"{JDBC_SECRET_ARN_ENV} environment variable is required")

    secret = boto3.client("secretsmanager").get_secret_value(SecretId=secret_arn)
    credentials = json.loads(secret["SecretString"])
    if not credentials.get("username") or not credentials.get("password"):
        raise ValueError("JDBC secret must contain username and password")
    print("[Step 2] SQL Server credentials loaded")
    return {
        "username": credentials["username"],
        "password": credentials["password"],
    }


def get_scheme_ids() -> Dict[str, int]:
    # Resolve the non-secret programme-to-SchemeID mapping supplied by Glue.
    print("[Step 3] Loading scheme IDs from Glue environment variables")
    values = {
        "PrivateBank": os.environ.get(PRIVATE_BANK_SCHEME_ID_ENV),
        "Premier": os.environ.get(PREMIER_SCHEME_ID_ENV),
    }
    if not all(values.values()):
        raise ValueError(
            f"{PRIVATE_BANK_SCHEME_ID_ENV} and {PREMIER_SCHEME_ID_ENV} environment variables are required"
        )
    scheme_ids = {name: int(value) for name, value in values.items()}
    print("[Step 3] Scheme IDs loaded")
    return scheme_ids


def parse_s3_uri(uri: str) -> Tuple[str, str]:
    parsed = urlparse(uri)
    if parsed.scheme != "s3" or not parsed.netloc:
        raise ValueError(f"Expected S3 URI, got {uri}")
    return parsed.netloc, parsed.path.lstrip("/")


def source_file_id(bucket: str, source_object: Dict) -> str:
    identity = "\n".join([
        bucket,
        source_object["key"],
        source_object.get("version_id") or "",
        source_object["etag"],
        str(source_object["size"]),
    ])
    return hashlib.sha256(identity.encode("utf-8")).hexdigest()


def list_source_objects(source_path: str) -> List[Dict]:
    # Snapshot the S3 keys that belong to this run.
    bucket, prefix = parse_s3_uri(source_path)
    print(f"[Step 4] Listing source objects under s3://{bucket}/{prefix}")
    client = boto3.client("s3")
    paginator = client.get_paginator("list_objects_v2")
    source_objects = []
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for item in page.get("Contents", []):
            key = item["Key"]
            if not key.endswith("/"):
                head = client.head_object(Bucket=bucket, Key=key)
                source_object = {
                    "key": key,
                    "etag": head["ETag"].strip('"'),
                    "size": head["ContentLength"],
                    "version_id": head.get("VersionId"),
                }
                source_object["file_id"] = source_file_id(bucket, source_object)
                source_objects.append(source_object)
    print(f"[Step 4] Found {len(source_objects)} source object(s)")
    return source_objects


def read_s3_chunks(
    source_path: str,
    source_object: Dict,
    delimiter: str,
) -> Iterator[Tuple[int, pd.DataFrame]]:
    # Stream each S3 CSV in bounded Pandas chunks to limit memory usage.
    bucket, _ = parse_s3_uri(source_path)
    client = boto3.client("s3")
    key = source_object["key"]
    print(f"[Step 7] Reading S3 object s3://{bucket}/{key}")
    get_options = {"Bucket": bucket, "Key": key}
    if source_object.get("version_id"):
        get_options["VersionId"] = source_object["version_id"]
    response = client.get_object(**get_options)
    for chunk_number, chunk in enumerate(pd.read_csv(
        response["Body"],
        sep=delimiter,
        dtype=str,
        keep_default_na=False,
        chunksize=PANDAS_CHUNK_SIZE,
    ), start=1):
        first_row = ((chunk_number - 1) * PANDAS_CHUNK_SIZE) + 2
        chunk["_source_row_number"] = range(first_row, first_row + len(chunk))
        print(f"[Step 7] Read chunk {chunk_number} from {key}: {len(chunk)} row(s)")
        yield chunk_number, chunk
    print(f"[Step 7] Finished reading S3 object s3://{bucket}/{key}")


def parse_jdbc_url(jdbc_url: str) -> Tuple[str, int, str, Dict[str, str]]:
    match = re.match(r"^jdbc:sqlserver://([^:;]+)(?::(\d+))?;(.*)$", jdbc_url)
    if not match:
        raise ValueError("JDBC_URL must be a SQL Server JDBC URL")

    host = match.group(1)
    port = int(match.group(2) or 1433)
    properties = {}
    for item in match.group(3).split(";"):
        if "=" in item:
            key, value = item.split("=", 1)
            properties[key.lower()] = unquote(value)
    database = properties.get("databasename")
    if not database:
        raise ValueError("JDBC_URL must include databaseName")
    return host, port, database, properties


def connect_sql_server(jdbc_url: str, credentials: Dict[str, str]):
    # Convert the existing JDBC-style URL into pymssql connection parameters.
    host, port, database, _ = parse_jdbc_url(jdbc_url)
    print(f"[Step 5] Connecting to SQL Server {host}:{port}/{database}")
    connection = pymssql.connect(
        server=host,
        port=port,
        user=credentials["username"],
        password=credentials["password"],
        database=database,
        login_timeout=30,
        timeout=60,
        charset="UTF-8",
        autocommit=False,
    )
    print("[Step 5] Connected to database")
    return connection


def quote_name(name: str) -> str:
    return "[" + name.replace("]", "]]") + "]"


def split_table_name(table_name: str) -> str:
    return ".".join(quote_name(part) for part in table_name.split("."))


def normalize_string_series(series: pd.Series) -> pd.Series:
    if isinstance(series, pd.DataFrame):
        raise ValueError(
            f"Expected one column but received duplicate columns: "
            f"{series.columns.tolist()}"
        )
    return series.fillna("").astype(str).str.strip()


def coalesce_duplicate_columns(
    df: pd.DataFrame,
    context: str,
) -> pd.DataFrame:
    # Selecting a duplicate column name returns a DataFrame, which breaks code
    # expecting a Series and calling .str. Keep the first non-empty value from
    # left to right so every downstream column name is unique.
    duplicate_names = df.columns[df.columns.duplicated()].unique().tolist()
    if not duplicate_names:
        return df.copy()

    print(f"[Chunk] Coalescing duplicate {context} column(s): {duplicate_names}")
    coalesced = pd.DataFrame(index=df.index)
    for column in dict.fromkeys(df.columns):
        values = df.loc[:, df.columns == column]
        if values.shape[1] == 1:
            coalesced[column] = values.iloc[:, 0]
            continue

        normalized = values.fillna("").astype(str).apply(
            lambda series: series.str.strip()
        )
        coalesced[column] = normalized.replace("", pd.NA).bfill(axis=1).iloc[:, 0].fillna("")
    return coalesced


def rename_and_coalesce_columns(raw_df: pd.DataFrame) -> pd.DataFrame:
    # Multiple source aliases can map to the same canonical name.
    renamed = raw_df.rename(
        columns={
            source: target
            for source, target in FIELD_RENAMES.items()
            if source in raw_df.columns
        }
    )
    return coalesce_duplicate_columns(renamed, "mapped source")


def require_unique_columns(
    df: pd.DataFrame,
    required_columns: List[str],
    context: str,
) -> None:
    missing = [column for column in required_columns if column not in df.columns]
    duplicates = [
        column for column in required_columns
        if list(df.columns).count(column) > 1
    ]
    if missing or duplicates:
        raise ValueError(
            f"{context} has invalid columns; missing={missing}, "
            f"duplicates={duplicates}"
        )


def log_dataframe_schema(df: pd.DataFrame, context: str) -> None:
    duplicates = df.columns[df.columns.duplicated()].unique().tolist()
    print(
        f"[Schema] {context}: rows={len(df)}, columns={len(df.columns)}, "
        f"duplicate_columns={duplicates}"
    )


def run_dataframe_stage(stage_name: str, function, *dataframes):
    sanitized = []
    for index, dataframe in enumerate(dataframes, start=1):
        if not isinstance(dataframe, pd.DataFrame):
            sanitized.append(dataframe)
            continue
        clean = coalesce_duplicate_columns(
            dataframe,
            f"{stage_name} input {index}",
        )
        log_dataframe_schema(clean, f"{stage_name} input {index}")
        sanitized.append(clean)

    try:
        return function(*sanitized)
    except Exception as error:
        print(
            f"[Stage Error] {stage_name} failed with "
            f"{type(error).__name__}: {error}"
        )
        traceback.print_exc()
        raise


def reject_unmapped_schemes(
    valid_df: pd.DataFrame,
) -> Tuple[pd.DataFrame, pd.DataFrame]:
    # A programme reference that is not in scheme_ids maps to NaN. Reject it
    # before downstream validation attempts to convert scheme_id to an integer.
    scheme_ids = pd.to_numeric(valid_df["scheme_id"], errors="coerce")
    unmapped_mask = scheme_ids.isna()
    if not unmapped_mask.any():
        accepted = valid_df.copy()
        accepted["scheme_id"] = scheme_ids.astype("int64")
        return accepted, valid_df.iloc[0:0].copy()

    rejects = valid_df.loc[unmapped_mask].copy()
    rejects["validation_reason_codes"] = "UNMAPPED_PRIMARY_PROGRAMME_REFERENCE"
    accepted = valid_df.loc[~unmapped_mask].copy()
    accepted["scheme_id"] = scheme_ids.loc[~unmapped_mask].astype("int64")
    print(
        f"[Chunk] Rejected {len(rejects)} row(s) with unmapped programme "
        f"reference(s): "
        f"{rejects['primary_programme_reference'].value_counts(dropna=False).to_dict()}"
    )
    return accepted, rejects


def target_rows_for_email_conflicts(target_df: pd.DataFrame) -> pd.DataFrame:
    # Existing rows without a SchemeID cannot participate in a same-scheme
    # email conflict and must not be passed to code that converts it to int.
    target_df = coalesce_duplicate_columns(target_df, "target")
    if "SchemeID" not in target_df.columns:
        return target_df

    scheme_ids = pd.to_numeric(target_df["SchemeID"], errors="coerce")
    invalid_mask = scheme_ids.isna()
    if invalid_mask.any():
        print(
            f"[Chunk] Ignoring {int(invalid_mask.sum())} target row(s) with "
            "missing or invalid SchemeID during email conflict checks"
        )
    usable = target_df.loc[~invalid_mask].copy()
    usable["SchemeID"] = scheme_ids.loc[~invalid_mask].astype("int64")
    return usable


def map_to_ten_standard(
    raw_df: pd.DataFrame,
    source_uri: str,
    scheme_ids: Dict[str, int],
) -> pd.DataFrame:
    # Normalize feed column names and values into the shared TEN staging schema.
    df = rename_and_coalesce_columns(raw_df)
    for column in TEN_STANDARD_COLUMNS:
        if column not in df.columns:
            df[column] = ""
        df[column] = normalize_string_series(df[column])

    df["primary_member_reference"] = df["primary_member_reference"].str.upper()
    df["email_address"] = df["email_address"].str.lower()
    df["country_code"] = df["country_code"].str.upper()
    for column in ["main_phone", "business_phone", "home_phone"]:
        df[column] = df[column].str.replace(r"\s+", "", regex=True)

    df["scheme_id"] = df["primary_programme_reference"].map(scheme_ids)
    df["file_name"] = source_uri
    mapped = df[STAGING_COLUMNS]
    require_unique_columns(mapped, STAGING_COLUMNS, "Mapped source data")
    print(f"[Chunk] Mapping completed for {len(mapped)} row(s)")
    return mapped


def read_target(connection, target_table: str) -> pd.DataFrame:
    # Load the current Members state used for conflict checks and change detection.
    query = f"SELECT * FROM {split_table_name(target_table)}"
    print(f"[Step 6] Loading database table {target_table}")
    target_df = pd.read_sql_query(query, connection)
    target_df = coalesce_duplicate_columns(target_df, "target table")
    print(f"[Step 6] Loaded {len(target_df)} database row(s)")
    return target_df


def sql_value(value):
    if pd.isna(value):
        return None
    if isinstance(value, pd.Timestamp):
        return value.to_pydatetime()
    if isinstance(value, date) and not isinstance(value, datetime):
        return datetime.combine(value, time.min)
    return value.item() if hasattr(value, "item") else value


def rows_for_bulk_copy(df: pd.DataFrame, columns: List[str]) -> Iterator[Tuple]:
    for row in df[columns].itertuples(index=False, name=None):
        yield tuple(sql_value(value) for value in row)


def write_to_members(
    connection,
    members_df: pd.DataFrame,
    target_table: str,
) -> None:
    # Stage and upsert changed members in one transaction for the current input chunk.
    if members_df.empty:
        print("[Chunk] No member rows to write")
        return

    print(f"[Chunk] Writing {len(members_df)} member row(s) to database")
    quoted_table = split_table_name(target_table)
    quoted_staging_table = quote_name(STAGING_TABLE)
    columns = members_df.columns.tolist()
    column_sql = ", ".join(quote_name(column) for column in columns)
    cursor = connection.cursor()
    try:
        # Start every chunk from a clean transaction boundary. Staging, delete,
        # and target insert are committed together.
        connection.rollback()
        cursor.execute("SET XACT_ABORT ON")
        print("[Chunk] Database transaction started")

        print(f"[Chunk DB 1/4] Creating temporary staging table {STAGING_TABLE}")
        cursor.execute(
            f"IF OBJECT_ID('tempdb..{STAGING_TABLE}') IS NOT NULL "
            f"DROP TABLE {quoted_staging_table}"
        )
        cursor.execute(
            f"SELECT TOP (0) {column_sql} "
            f"INTO {quoted_staging_table} "
            f"FROM {quoted_table}"
        )
        print(f"[Chunk DB 1/4] Created temporary staging table {STAGING_TABLE}")

        print(
            f"[Chunk DB 2/4] Bulk copying {len(members_df)} row(s) "
            f"into temporary staging table {STAGING_TABLE}"
        )
        connection.bulk_copy(
            STAGING_TABLE,
            rows_for_bulk_copy(members_df, columns),
            batch_size=SQL_BATCH_SIZE,
            tablock=True,
        )
        staged = len(members_df)
        print(f"[Chunk DB 2/4] Bulk copied {staged} staging row(s)")

        print("[Chunk DB 3/4] Deleting matching target rows")
        cursor.execute(
            f"DELETE target_rows "
            f"FROM {quoted_table} AS target_rows "
            f"INNER JOIN {quoted_staging_table} AS staged_rows "
            f"ON target_rows.{quote_name('SchemeID')} = "
            f"staged_rows.{quote_name('SchemeID')} "
            f"AND target_rows.{quote_name('Reference1')} = "
            f"staged_rows.{quote_name('Reference1')}"
        )
        deleted = cursor.rowcount
        print(f"[Chunk DB 3/4] Deleted {deleted} matching target row(s)")

        print(f"[Chunk DB 4/4] Inserting {staged} staged row(s) into target table")
        cursor.execute(
            f"INSERT INTO {quoted_table} ({column_sql}) "
            f"SELECT {column_sql} FROM {quoted_staging_table}"
        )
        inserted = cursor.rowcount
        print(f"[Chunk DB 4/4] Inserted {inserted} staged row(s) into target table")

        print(f"[Chunk] Dropping temporary staging table {STAGING_TABLE}")
        cursor.execute(f"DROP TABLE {quoted_staging_table}")
        print(f"[Chunk] Dropped temporary staging table {STAGING_TABLE}")

        # This is the only commit in the chunk upsert.
        connection.commit()
        print("[Chunk] Database transaction committed")
        print(f"[Chunk] Finished writing {inserted} member row(s) to database")
    except Exception as error:
        print(f"[Chunk] Database upsert failed; rolling back: {error}")
        try:
            connection.rollback()
            print("[Chunk] Database transaction rolled back")
        except Exception as rollback_error:
            print(f"[Chunk] Database rollback also failed: {rollback_error}")
        raise
    finally:
        cursor.close()


def chunk_key(prefix: str, file_id: str, chunk_number: int, filename: str) -> str:
    return (
        f"{prefix.rstrip('/')}/file_id={file_id}/"
        f"chunk={chunk_number:06d}/{filename}"
    )


def checkpoint_exists(checkpoint_path: str, file_id: str, chunk_number: int) -> bool:
    bucket, prefix = parse_s3_uri(checkpoint_path)
    key = chunk_key(prefix, file_id, chunk_number, "complete.json")
    try:
        boto3.client("s3").head_object(Bucket=bucket, Key=key)
        return True
    except ClientError as error:
        if error.response.get("Error", {}).get("Code") in {"404", "NoSuchKey", "NotFound"}:
            return False
        raise


def write_chunk_checkpoint(
    checkpoint_path: str,
    source_object: Dict,
    chunk_number: int,
    input_rows: int,
    written_rows: int,
    reject_rows: int,
) -> None:
    bucket, prefix = parse_s3_uri(checkpoint_path)
    key = chunk_key(prefix, source_object["file_id"], chunk_number, "complete.json")
    payload = {
        "file_id": source_object["file_id"],
        "source_key": source_object["key"],
        "source_etag": source_object["etag"],
        "source_version_id": source_object.get("version_id"),
        "chunk_number": chunk_number,
        "input_rows": input_rows,
        "database_rows_written": written_rows,
        "reject_rows": reject_rows,
        "status": "complete",
    }
    boto3.client("s3").put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(payload, sort_keys=True).encode("utf-8"),
        ContentType="application/json",
    )
    print(f"[Checkpoint] Wrote s3://{bucket}/{key}")


def add_reject_audit_fields(
    rejects_df: pd.DataFrame,
    source_object: Dict,
    chunk_number: int,
) -> pd.DataFrame:
    if rejects_df.empty:
        return rejects_df

    audited = rejects_df.copy()
    audited["source_file_id"] = source_object["file_id"]
    audited["source_object_key"] = source_object["key"]
    audited["source_etag"] = source_object["etag"]
    audited["source_version_id"] = source_object.get("version_id") or ""
    audited["source_chunk_number"] = chunk_number
    audited["reject_id"] = audited.apply(
        lambda row: hashlib.sha256(
            (
                f"{source_object['file_id']}|{row['_source_row_number']}|"
                f"{row.get('validation_reason_codes', '')}"
            ).encode("utf-8")
        ).hexdigest(),
        axis=1,
    )
    return audited


def write_chunk_rejects(
    rejects_df: pd.DataFrame,
    error_path: str,
    source_object: Dict,
    chunk_number: int,
) -> None:
    if rejects_df.empty:
        print("[Chunk] No reject rows")
        return

    bucket, prefix = parse_s3_uri(error_path)
    key = chunk_key(prefix, source_object["file_id"], chunk_number, "rejects.csv")
    buffer = io.StringIO()
    rejects_df.to_csv(buffer, index=False)
    print(f"[Chunk] Writing {len(rejects_df)} reject row(s) to s3://{bucket}/{key}")
    boto3.client("s3").put_object(
        Bucket=bucket,
        Key=key,
        Body=buffer.getvalue().encode("utf-8"),
        ContentType="text/csv",
    )
    print(f"[Chunk] Finished writing rejects to s3://{bucket}/{key}")


def archive_source_object(
    source_object: Dict,
    source_path: str,
    archive_path: str,
) -> None:
    # Archive only after every chunk has a durable completion checkpoint.
    source_bucket, _ = parse_s3_uri(source_path)
    archive_bucket, archive_prefix = parse_s3_uri(archive_path)
    if source_bucket != archive_bucket:
        raise ValueError("SOURCE_S3_PATH and ARCHIVE_S3_PATH must use the same bucket")

    client = boto3.client("s3")
    source_key = source_object["key"]
    current = client.head_object(Bucket=source_bucket, Key=source_key)
    current_version_id = current.get("VersionId")
    current_etag = current["ETag"].strip('"')
    if (
        current_etag != source_object["etag"]
        or current["ContentLength"] != source_object["size"]
        or (
            source_object.get("version_id")
            and current_version_id != source_object["version_id"]
        )
    ):
        raise RuntimeError(
            f"Source object changed during processing; refusing to archive: "
            f"s3://{source_bucket}/{source_key}"
        )

    _, incoming_prefix = parse_s3_uri(source_path)
    relative_key = source_key[len(incoming_prefix):].lstrip("/")
    target_key = f"{archive_prefix.rstrip('/')}/{relative_key}"
    copy_source = {"Bucket": source_bucket, "Key": source_key}
    if source_object.get("version_id"):
        copy_source["VersionId"] = source_object["version_id"]

    print(f"[Step 10] Writing archive object to s3://{source_bucket}/{target_key}")
    client.copy_object(
        Bucket=source_bucket,
        CopySource=copy_source,
        Key=target_key,
    )
    # Delete the verified current key. On a versioned bucket this writes a delete
    # marker so older versions do not become visible to the next run.
    client.delete_object(Bucket=source_bucket, Key=source_key)
    print(f"[Step 10] Archived source object s3://{source_bucket}/{source_key}")


def update_target_snapshot(target_df: pd.DataFrame, members_df: pd.DataFrame) -> pd.DataFrame:
    # Keep later chunks aligned with rows committed by earlier chunks.
    if members_df.empty:
        print("[Chunk] Database snapshot unchanged")
        return target_df

    target = coalesce_duplicate_columns(target_df, "snapshot target")
    members_df = coalesce_duplicate_columns(members_df, "snapshot members")
    require_unique_columns(
        target,
        ["SchemeID", "Reference1"],
        "Snapshot target",
    )
    require_unique_columns(
        members_df,
        ["SchemeID", "Reference1"],
        "Snapshot members",
    )
    target["SchemeID"] = pd.to_numeric(target["SchemeID"], errors="coerce")
    target["Reference1"] = normalize_string_series(target["Reference1"])
    replacement_keys = pd.MultiIndex.from_frame(members_df[["SchemeID", "Reference1"]])
    target_keys = pd.MultiIndex.from_frame(target[["SchemeID", "Reference1"]])
    target = target.loc[~target_keys.isin(replacement_keys)].copy()

    replacement = members_df.reindex(columns=target.columns)
    updated = pd.concat([target, replacement], ignore_index=True, sort=False)
    print(f"[Chunk] Updated in-memory database snapshot to {len(updated)} row(s)")
    return updated


def process_chunk(
    raw_df: pd.DataFrame,
    source_uri: str,
    source_object: Dict,
    chunk_number: int,
    scheme_ids: Dict[str, int],
    target_df: pd.DataFrame,
    connection,
    target_table: str,
) -> Tuple[pd.DataFrame, pd.DataFrame]:
    # Step A: map source fields into the canonical staging schema.
    print(f"[Chunk] Mapping {len(raw_df)} input row(s)")
    mapped = map_to_ten_standard(raw_df, source_uri, scheme_ids)
    mapped["_source_row_number"] = raw_df["_source_row_number"].values

    # Step B: apply structural and business validation rules.
    print("[Chunk] Validating mapped rows")
    require_unique_columns(mapped, TEN_STANDARD_COLUMNS, "Validation input")
    checked = run_dataframe_stage(
        "with_validation_errors_pandas",
        with_validation_errors_pandas,
        mapped,
    )
    checked = coalesce_duplicate_columns(checked, "validation output")
    valid, invalid = run_dataframe_stage(
        "split_valid_invalid_pandas",
        split_valid_invalid_pandas,
        checked,
    )
    valid = coalesce_duplicate_columns(valid, "valid-row output")
    invalid = coalesce_duplicate_columns(invalid, "invalid-row output")
    print(f"[Chunk] Validation result: {len(valid)} valid, {len(invalid)} invalid")

    # Step C: reject rows whose programme reference has no configured scheme ID.
    valid, scheme_rejects = reject_unmapped_schemes(valid)

    # Step D: reject email addresses owned by another member in the same scheme.
    print("[Chunk] Checking email conflicts")
    conflict_target = target_rows_for_email_conflicts(target_df)
    if valid.empty:
        email_conflicts = valid.copy()
    else:
        require_unique_columns(
            valid,
            ["email_address", "scheme_id", "primary_member_reference"],
            "Email-conflict input",
        )
        valid, email_conflicts = run_dataframe_stage(
            "reject_email_conflicts_pandas",
            reject_email_conflicts_pandas,
            valid,
            conflict_target,
        )
        valid = coalesce_duplicate_columns(valid, "email-conflict valid output")
        email_conflicts = coalesce_duplicate_columns(
            email_conflicts,
            "email-conflict reject output",
        )
    print(
        f"[Chunk] Email conflict result: {len(valid)} valid, "
        f"{len(email_conflicts)} conflict reject(s)"
    )
    rejects = pd.concat(
        [invalid, scheme_rejects, email_conflicts],
        ignore_index=True,
        sort=False,
    )

    members = pd.DataFrame()
    if not valid.empty:
        # Step E: shape valid rows into dbo.Members and remove unchanged rows.
        print("[Chunk] Building Members model")
        members = run_dataframe_stage(
            "build_members_model_pandas",
            build_members_model_pandas,
            valid,
            target_df,
        )
        members = coalesce_duplicate_columns(members, "Members model")
        require_unique_columns(
            members,
            ["SchemeID", "Reference1"],
            "Members model",
        )
        members = members.drop_duplicates(["SchemeID", "Reference1"])
        print(f"[Chunk] Checking {len(members)} deduplicated member row(s) for changes")
        members = run_dataframe_stage(
            "filter_changed_pandas",
            filter_changed_pandas,
            members,
            target_df,
        )
        members = coalesce_duplicate_columns(members, "change-filter output")
        require_unique_columns(
            members,
            ["SchemeID", "Reference1"],
            "Change-filter output",
        )
        print(f"[Chunk] {len(members)} member row(s) require database upsert")

        # Step F: transactionally delete and insert changed member rows.
        write_to_members(connection, members, target_table)
    else:
        print("[Chunk] No valid rows; skipping database upsert")
    return rejects, members


def main() -> None:
    print("[Step 1] Starting HSBC Pandas ETL")

    # Step 1: resolve Glue arguments and runtime configuration.
    args = parse_args()
    print(f"[Step 1] Job arguments loaded for {args['JOB_NAME']}")

    # Steps 2-3: load credentials and scheme configuration.
    os.environ[JDBC_SECRET_ARN_ENV] = args["JDBC_SECRET_ARN"]
    credentials = get_jdbc_credentials()
    scheme_ids = get_scheme_ids()
    # Step 4: capture the source files expected in this run.
    source_objects = list_source_objects(args["SOURCE_S3_PATH"])
    if not source_objects:
        raise ValueError("No input files found")

    # Step 5: open the SQL Server connection.
    connection = connect_sql_server(args["JDBC_URL"], credentials)

    try:
        # Step 6: load the current database state once.
        target_df = read_target(connection, args["TARGET_TABLE"])
        processed_rows = 0
        processed_chunks = 0

        # Steps 7-10: process, checkpoint, and archive one immutable source object
        # at a time. A failed object remains under incoming/ for a manual rerun.
        source_bucket, _ = parse_s3_uri(args["SOURCE_S3_PATH"])
        for source_object in source_objects:
            object_chunks = 0
            source_uri = f"s3://{source_bucket}/{source_object['key']}"
            print(
                f"[Step 7] Processing source file {source_uri} "
                f"with file_id={source_object['file_id']}"
            )

            for chunk_number, raw_chunk in read_s3_chunks(
                args["SOURCE_S3_PATH"],
                source_object,
                args["INPUT_DELIMITER"],
            ):
                object_chunks += 1
                processed_chunks += 1
                processed_rows += len(raw_chunk)

                if checkpoint_exists(
                    args["CHECKPOINT_S3_PATH"],
                    source_object["file_id"],
                    chunk_number,
                ):
                    print(
                        f"[Checkpoint] Skipping completed file_id="
                        f"{source_object['file_id']} chunk={chunk_number}"
                    )
                    continue

                print(
                    f"[Step 8] Processing chunk {chunk_number} for "
                    f"{source_object['key']}; {processed_rows} total row(s) read"
                )
                rejects, written_members = process_chunk(
                    raw_chunk,
                    source_uri,
                    source_object,
                    chunk_number,
                    scheme_ids,
                    target_df,
                    connection,
                    args["TARGET_TABLE"],
                )
                target_df = update_target_snapshot(target_df, written_members)

                audited_rejects = add_reject_audit_fields(
                    rejects,
                    source_object,
                    chunk_number,
                )
                write_chunk_rejects(
                    audited_rejects,
                    args["ERROR_S3_PATH"],
                    source_object,
                    chunk_number,
                )
                write_chunk_checkpoint(
                    args["CHECKPOINT_S3_PATH"],
                    source_object,
                    chunk_number,
                    len(raw_chunk),
                    len(written_members),
                    len(audited_rejects),
                )
                print(f"[Step 8] Completed chunk {chunk_number}")

            if object_chunks == 0:
                raise ValueError(f"Source file is empty: {source_uri}")

            # Archive only after every chunk was either completed now or had an
            # existing durable checkpoint from a previous attempt.
            archive_source_object(
                source_object,
                args["SOURCE_S3_PATH"],
                args["ARCHIVE_S3_PATH"],
            )

        print(f"[Step 8] Processed {processed_rows} row(s) across {processed_chunks} chunk(s)")

        print("[Step 11] HSBC Pandas ETL completed")
    except Exception as error:
        print(f"[Error] HSBC Pandas ETL failed: {error}")
        traceback.print_exc()
        raise
    finally:
        # Step 12: release database and local temporary-file resources.
        print("[Step 12] Closing SQL Server connection")
        connection.close()
        print("[Step 12] Cleanup completed")


if __name__ == "__main__":
    main()
