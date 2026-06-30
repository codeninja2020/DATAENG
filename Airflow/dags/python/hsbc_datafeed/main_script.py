"""Chunked Pandas ETL for validating HSBC member feeds and upserting SQL Server.

Each input chunk follows seven logged steps:
1. Extract the input rows.
2. Transform them into the canonical staging schema.
3. Validate required fields, formats, and business rules.
4. Resolve programme names to SchemeID values.
5. Reject email ownership conflicts.
6. Build the Members model and detect changed rows.
7. Load changed rows into SQL Server in one transaction.
"""

import json
import hashlib
import io
import logging
from datetime import date, datetime, time
from time import perf_counter
from typing import Dict, Iterator, List, Tuple
from urllib.parse import urlparse

import boto3
import pandas as pd
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

PANDAS_CHUNK_SIZE = 100000
SQL_BATCH_SIZE = 100000
STAGING_TABLE = "#members_staging"
ETL_STEP_COUNT = 7

LOGGER = logging.getLogger(__name__)


def log_etl_step(
    step_number: int,
    step_name: str,
    message: str,
    *,
    source_uri: str = "",
    chunk_number: int = 0,
) -> None:
    """Write a consistently formatted ETL progress message to Airflow logs."""
    context = []
    if source_uri:
        context.append(f"source={source_uri}")
    if chunk_number:
        context.append(f"chunk={chunk_number}")
    context_text = f" [{' '.join(context)}]" if context else ""
    LOGGER.info(
        "[ETL Step %s/%s: %s]%s %s",
        step_number,
        ETL_STEP_COUNT,
        step_name,
        context_text,
        message,
    )


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
    stage_started = perf_counter()
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
        result = function(*sanitized)
        LOGGER.info(
            "[ETL Stage: %s] completed in %.3f seconds",
            stage_name,
            perf_counter() - stage_started,
        )
        return result
    except Exception as error:
        LOGGER.exception(
            "[ETL Stage: %s] failed after %.3f seconds: %s: %s",
            stage_name,
            perf_counter() - stage_started,
            type(error).__name__,
            error,
        )
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


def read_target(
    connection,
    target_table: str,
    member_references: List[str] = None,
) -> pd.DataFrame:
    # Load only the current Members rows needed for conflict checks and change
    # detection. SQL Server accepts at most 2,100 parameters, so large CIN sets
    # are queried in bounded batches.
    started = perf_counter()
    quoted_table = split_table_name(target_table)
    references = sorted({
        str(reference).strip().upper()
        for reference in (member_references or [])
        if str(reference).strip()
    })
    LOGGER.info(
        "[ETL Setup] Loading current rows from %s for %s feed CIN(s)",
        target_table,
        len(references),
    )

    if not references:
        target_df = pd.read_sql_query(
            f"SELECT TOP (0) * FROM {quoted_table}",
            connection,
        )
    else:
        frames = []
        parameter_batch_size = 2000
        for start in range(0, len(references), parameter_batch_size):
            batch = references[start:start + parameter_batch_size]
            placeholders = ", ".join(["%s"] * len(batch))
            query = (
                f"SELECT * FROM {quoted_table} "
                f"WHERE UPPER(LTRIM(RTRIM({quote_name('Reference1')}))) "
                f"IN ({placeholders})"
            )
            frames.append(pd.read_sql_query(query, connection, params=batch))
        target_df = pd.concat(frames, ignore_index=True, sort=False)

    target_df = coalesce_duplicate_columns(target_df, "target table")
    LOGGER.info(
        "[ETL Setup] Loaded %s matching database row(s) from %s in %.3f seconds",
        len(target_df),
        target_table,
        perf_counter() - started,
    )
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
        LOGGER.info("[ETL Load] No changed member rows to write")
        return

    load_started = perf_counter()
    LOGGER.info(
        "[ETL Load] Writing %s member row(s) to %s",
        len(members_df),
        target_table,
    )
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
        LOGGER.info(
            "[ETL Load] Committed %s member row(s) to %s in %.3f seconds",
            inserted,
            target_table,
            perf_counter() - load_started,
        )
    except Exception as error:
        LOGGER.exception(
            "[ETL Load] Database upsert failed after %.3f seconds; rolling back: %s",
            perf_counter() - load_started,
            error,
        )
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
    return_all_members: bool = False,
):
    chunk_started = perf_counter()

    # Step 1: receive the extracted input chunk and record its source context.
    log_etl_step(
        1,
        "Extract",
        f"Received {len(raw_df)} input row(s)",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )

    # Step 2: map source fields into the canonical staging schema.
    log_etl_step(
        2,
        "Transform",
        "Normalizing columns and mapping programme names to SchemeID values",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )
    mapped = map_to_ten_standard(raw_df, source_uri, scheme_ids)
    mapped["_source_row_number"] = raw_df["_source_row_number"].values
    log_etl_step(
        2,
        "Transform",
        f"Mapped {len(mapped)} row(s) to the canonical staging schema",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )

    # Step 3: apply structural and business validation rules.
    log_etl_step(
        3,
        "Validate",
        "Applying required-field, format, and business validation rules",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )
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
    log_etl_step(
        3,
        "Validate",
        f"Validation produced {len(valid)} valid and {len(invalid)} invalid row(s)",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )

    # Step 4: reject rows whose programme reference has no configured scheme ID.
    log_etl_step(
        4,
        "Resolve schemes",
        "Checking that every programme has a configured SchemeID",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )
    valid, scheme_rejects = reject_unmapped_schemes(valid)
    log_etl_step(
        4,
        "Resolve schemes",
        f"Accepted {len(valid)} row(s); rejected {len(scheme_rejects)} unmapped row(s)",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )

    # Step 5: reject email addresses owned by another member in the same scheme.
    log_etl_step(
        5,
        "Check conflicts",
        "Checking email ownership conflicts against current database rows",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )
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
    log_etl_step(
        5,
        "Check conflicts",
        f"Accepted {len(valid)} row(s); rejected "
        f"{len(email_conflicts)} email conflict row(s)",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )
    rejects = pd.concat(
        [invalid, scheme_rejects, email_conflicts],
        ignore_index=True,
        sort=False,
    )

    members = pd.DataFrame()
    all_members = pd.DataFrame()

    # Step 6: build the target model and retain only new or changed rows.
    log_etl_step(
        6,
        "Detect changes",
        "Building the Members model and comparing it with current database rows",
        source_uri=source_uri,
        chunk_number=chunk_number,
    )
    if not valid.empty:
        all_members = run_dataframe_stage(
            "build_members_model_pandas",
            build_members_model_pandas,
            valid,
            target_df,
        )
        all_members = coalesce_duplicate_columns(all_members, "Members model")
        require_unique_columns(
            all_members,
            ["SchemeID", "Reference1"],
            "Members model",
        )
        all_members = all_members.drop_duplicates(["SchemeID", "Reference1"])
        print(
            f"[Chunk] Checking {len(all_members)} deduplicated member row(s) "
            "for changes"
        )
        members = run_dataframe_stage(
            "filter_changed_pandas",
            filter_changed_pandas,
            all_members,
            target_df,
        )
        members = coalesce_duplicate_columns(members, "change-filter output")
        require_unique_columns(
            members,
            ["SchemeID", "Reference1"],
            "Change-filter output",
        )
        log_etl_step(
            6,
            "Detect changes",
            f"Built {len(all_members)} member row(s); "
            f"{len(members)} row(s) require an upsert",
            source_uri=source_uri,
            chunk_number=chunk_number,
        )

        # Step 7: transactionally load changed rows into SQL Server.
        log_etl_step(
            7,
            "Load",
            f"Upserting {len(members)} changed member row(s) into {target_table}",
            source_uri=source_uri,
            chunk_number=chunk_number,
        )
        write_to_members(connection, members, target_table)
    else:
        log_etl_step(
            6,
            "Detect changes",
            "No valid rows are available for model construction",
            source_uri=source_uri,
            chunk_number=chunk_number,
        )
        log_etl_step(
            7,
            "Load",
            "Skipped database upsert because no valid rows remain",
            source_uri=source_uri,
            chunk_number=chunk_number,
        )

    LOGGER.info(
        "[ETL Complete] source=%s chunk=%s input=%s accepted=%s rejected=%s "
        "changed=%s elapsed_seconds=%.3f",
        source_uri,
        chunk_number,
        len(raw_df),
        len(all_members),
        len(rejects),
        len(members),
        perf_counter() - chunk_started,
    )
    if return_all_members:
        return rejects, members, all_members
    return rejects, members
