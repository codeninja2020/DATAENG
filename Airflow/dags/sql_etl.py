"""Helpers for deploying HSBC SQL ETL stored procedure scripts."""

import csv
import re
import uuid
from pathlib import Path

from airflow.hooks.base import BaseHook

DAG_DIR = Path(__file__).resolve().parent
SCHEMA_SQL_DIR = DAG_DIR / "sql_datafeed" / "schema"
STORED_PROCEDURE_SQL_DIR = DAG_DIR / "sql_datafeed" / "stored_procedures"
LOCAL_DATAFEED_PATH = DAG_DIR / "datafeeds" / "hsbc" / "members_datafeed_example.csv"
CONNECTION_ID = "mssql_default"
PRIVATE_BANK_SCHEME_ID = 1591
PREMIER_SCHEME_ID = 1587

DATAFEED_COLUMNS = (
    "CIN",
    "segment",
    "scheme_name",
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
    "business_phone",
    "home_phone",
)

SCHEMA_SCRIPT_ORDER = (
    "V5.37__HSBC_ETL_create_rawdatafeed_table.sql",
    "V5.38__HSBC_ETL_create_ucodes_table.sql",
    "V5.39__HSBC_ETL_create_tempmembers_table.sql",
    "V5.40__HSBC_ETL_create_s3_download_tracking_table.sql",
    "V5.41__HSBC_ETL_create_datafeederrors_table.sql",
)

EXPECTED_SCHEMA_TABLES = (
    "HSBC_ETL.rawdatafeed",
    "HSBC_ETL.ucodes",
    "HSBC_ETL.tempmembers",
    "HSBC_ETL.S3_Download_Tracking",
    "HSBC_ETL.datafeederrors",
)

SCRIPT_ORDER = (
    "R__HSBC_ETL_validate_load_datafeed.sql",
)


def schema_scripts(include_datafeed_errors: bool = True) -> list[Path]:
    script_names = [
        name
        for name in SCHEMA_SCRIPT_ORDER
        if include_datafeed_errors
        or name != "V5.41__HSBC_ETL_create_datafeederrors_table.sql"
    ]
    scripts = [SCHEMA_SQL_DIR / name for name in script_names]
    missing_scripts = [str(path) for path in scripts if not path.is_file()]
    if missing_scripts:
        raise FileNotFoundError(
            "Missing schema SQL script(s): " + ", ".join(missing_scripts)
        )
    return scripts


def stored_procedure_scripts() -> list[Path]:
    scripts = [STORED_PROCEDURE_SQL_DIR / name for name in SCRIPT_ORDER]
    missing_scripts = [str(path) for path in scripts if not path.is_file()]
    if missing_scripts:
        raise FileNotFoundError(
            "Missing stored procedure SQL script(s): " + ", ".join(missing_scripts)
        )
    return scripts


def _database_connection(connection_id: str = CONNECTION_ID):
    connection = BaseHook.get_connection(connection_id)
    return connection.get_hook().get_conn()


def split_sql_server_batches(sql: str) -> list[str]:
    """Split SQL Server scripts on standalone GO batch separators."""
    batches = re.split(
        r"^\s*GO(?:\s+\d+)?\s*(?:--.*)?$",
        sql,
        flags=re.IGNORECASE | re.MULTILINE,
    )
    return [batch.strip() for batch in batches if batch.strip()]


def _starting_database(script_name: str) -> str | None:
    if script_name == "R__HSBC_ETL_SQLAgentJob.sql":
        return "msdb"
    return None


def _prepare_sql(sql: str) -> str:
    if "__HSBC_LOCAL_DATAFEED_PATH__" in sql and not LOCAL_DATAFEED_PATH.is_file():
        raise FileNotFoundError(f"Local HSBC datafeed not found: {LOCAL_DATAFEED_PATH}")

    local_datafeed_path = str(LOCAL_DATAFEED_PATH).replace("'", "''")
    return sql.replace("__HSBC_LOCAL_DATAFEED_PATH__", local_datafeed_path)


def run_sql_script(script_path: Path, connection_id: str = CONNECTION_ID) -> dict:
    script_name = script_path.name
    sql = _prepare_sql(script_path.read_text(encoding="utf-8-sig"))
    batches = split_sql_server_batches(sql)

    connection = _database_connection(connection_id)
    try:
        cursor = connection.cursor()
        try:
            starting_database = _starting_database(script_name)
            if starting_database:
                cursor.execute(f"USE {starting_database}")

            for batch in batches:
                cursor.execute(batch)

            connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            cursor.close()
    finally:
        connection.close()

    return {
        "connection_id": connection_id,
        "script": script_name,
        "batches": len(batches),
    }


def run_schema_script(
    script_name: str,
    connection_id: str = CONNECTION_ID,
) -> dict:
    script_path = SCHEMA_SQL_DIR / script_name
    return run_sql_script(script_path, connection_id=connection_id)


def run_stored_procedure_script(
    script_name: str,
    connection_id: str = CONNECTION_ID,
) -> dict:
    script_path = STORED_PROCEDURE_SQL_DIR / script_name
    return run_sql_script(script_path, connection_id=connection_id)


def verify_schema_tables(
    include_datafeed_errors: bool = True,
    connection_id: str = CONNECTION_ID,
) -> dict:
    expected_tables = [
        table
        for table in EXPECTED_SCHEMA_TABLES
        if include_datafeed_errors or table != "HSBC_ETL.datafeederrors"
    ]
    placeholders = ", ".join("?" for _ in expected_tables)
    query = f"""
    SELECT CONCAT(SCHEMA_NAME(schema_id), '.', name) AS table_name
    FROM sys.tables
    WHERE CONCAT(SCHEMA_NAME(schema_id), '.', name) IN ({placeholders})
    """

    connection = _database_connection(connection_id)
    try:
        cursor = connection.cursor()
        try:
            cursor.execute("USE TENMAID_UAT")
            cursor.execute(query, *expected_tables)
            existing_tables = {row[0] for row in cursor.fetchall()}
        finally:
            cursor.close()
    finally:
        connection.close()

    missing_tables = sorted(set(expected_tables) - existing_tables)
    if missing_tables:
        raise RuntimeError(
            "Missing HSBC schema table(s): " + ", ".join(missing_tables)
        )

    return {
        "connection_id": connection_id,
        "tables": sorted(existing_tables),
    }


def _csv_rows() -> list[tuple[str | None, ...]]:
    if not LOCAL_DATAFEED_PATH.is_file():
        raise FileNotFoundError(f"Local HSBC datafeed not found: {LOCAL_DATAFEED_PATH}")

    with LOCAL_DATAFEED_PATH.open(newline="", encoding="utf-8-sig") as csv_file:
        reader = csv.DictReader(csv_file)
        if reader.fieldnames != list(DATAFEED_COLUMNS):
            raise ValueError(
                "Unexpected HSBC datafeed columns. "
                f"Expected {list(DATAFEED_COLUMNS)}, got {reader.fieldnames}"
            )
        return [
            tuple((row[column].strip() or None) for column in DATAFEED_COLUMNS)
            for row in reader
        ]


def load_local_datafeed_to_raw(connection_id: str = CONNECTION_ID) -> dict:
    rows = _csv_rows()
    if not rows:
        raise ValueError(f"Local HSBC datafeed is empty: {LOCAL_DATAFEED_PATH}")

    process_id = str(uuid.uuid4())
    rows_with_audit = [
        (*row, str(LOCAL_DATAFEED_PATH), process_id)
        for row in rows
    ]

    insert_sql = f"""
    INSERT INTO HSBC_ETL.rawdatafeed
    (
        {", ".join(DATAFEED_COLUMNS)},
        load_ts,
        source,
        dq_passed,
        processid
    )
    VALUES
    (
        {", ".join("?" for _ in DATAFEED_COLUMNS)},
        SYSDATETIME(),
        ?,
        0,
        ?
    )
    """

    connection = _database_connection(connection_id)
    try:
        cursor = connection.cursor()
        try:
            cursor.execute("TRUNCATE TABLE HSBC_ETL.rawdatafeed")
            if hasattr(cursor, "fast_executemany"):
                cursor.fast_executemany = True
            cursor.executemany(insert_sql, rows_with_audit)
            connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            cursor.close()
    finally:
        connection.close()

    return {
        "connection_id": connection_id,
        "rows": len(rows),
        "processid": process_id,
    }


def run_validate_and_load(connection_id: str = CONNECTION_ID) -> list[dict]:
    connection = _database_connection(connection_id)
    try:
        cursor = connection.cursor()
        try:
            cursor.execute(
                """
                EXEC HSBC_ETL.Validate_And_Load_Datafeed_To_TempMembers
                    @PrivateBankSchemeID = ?,
                    @PremierSchemeID = ?
                """,
                PRIVATE_BANK_SCHEME_ID,
                PREMIER_SCHEME_ID,
            )
            rows = cursor.fetchall()
            columns = [column[0] for column in cursor.description]
            connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            cursor.close()
    finally:
        connection.close()

    return [
        {
            "connection_id": connection_id,
            **dict(zip(columns, row)),
        }
        for row in rows
    ]
