"""Load local HSBC CSV datafeeds into SQL Server using discrete Airflow tasks."""

import hashlib
import os
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd
from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.operators.python import PythonOperator

DAG_DIR = Path(__file__).resolve().parent
HSBC_PYTHON_DIR = DAG_DIR / "python" / "hsbc_datafeed"
DATAFEED_DIR = DAG_DIR / "datafeeds" / "hsbc"
REJECT_DIR = DATAFEED_DIR / "errors" #error directory 
WORK_DIR = DATAFEED_DIR / ".work"

SCHEME_IDS = {
    "PrivateBank": 1591,
    "Premier": 1587,
}

if str(HSBC_PYTHON_DIR) not in sys.path:
    sys.path.insert(0, str(HSBC_PYTHON_DIR))

from main_script import (  # noqa: E402
    PANDAS_CHUNK_SIZE,
    TEN_STANDARD_COLUMNS,
    add_reject_audit_fields,
    coalesce_duplicate_columns,
    map_to_ten_standard,
    read_target,
    reject_unmapped_schemes,
    require_unique_columns,
    run_dataframe_stage,
    target_rows_for_email_conflicts,
    write_to_members,
)
from load import build_members_model_pandas, filter_changed_pandas  # noqa: E402

from validation import (  # noqa: E402
    reject_email_conflicts_pandas,
    split_valid_invalid_pandas,
    with_validation_errors_pandas,
)

def _source_object(path: Path) -> dict:
    stat = path.stat()
    identity = f"{path.name}\n{stat.st_size}\n{stat.st_mtime_ns}"
    return {
        "key": path.name,
        "etag": hashlib.sha256(identity.encode("utf-8")).hexdigest(),
        "size": stat.st_size,
        "version_id": None,
        "file_id": hashlib.sha256(
            str(path.resolve()).encode("utf-8") + identity.encode("utf-8")
        ).hexdigest(),
    }


def _database_connection():
    connection = BaseHook.get_connection("mssql_default")
    return connection.get_hook().get_conn()


def _run_directory(run_id: str) -> Path:
    safe_run_id = re.sub(r"[^A-Za-z0-9_.-]+", "_", run_id)
    path = WORK_DIR / safe_run_id
    path.mkdir(parents=True, exist_ok=True)
    return path


def _write_frame(frame: pd.DataFrame, path: Path) -> str:
    path.parent.mkdir(parents=True, exist_ok=True)
    frame.to_pickle(path)
    return str(path)


def _read_frame(path: str) -> pd.DataFrame:
    return pd.read_pickle(path)


with DAG(
    dag_id="hsbc_datafeed",
    schedule_interval="0 14 * * *",
    start_date=datetime(2026, 6, 21),
    catchup=False,
    default_args={
        "owner": "data-eng",
        "retries": 0,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["hsbc", "datafeed", "mssql"],
) as dag:
    def connect_to_db() -> dict:
        """Verify the Airflow SQL Server connection before starting the run."""
        connection = _database_connection()
        try:
            cursor = connection.cursor()
            try:
                cursor.execute("SELECT 1")
                cursor.fetchone()
            finally:
                cursor.close()
        finally:
            connection.close()
        return {"connection_id": "mssql_default"}

    def load_dbo_members(**context) -> dict:
        """Load dbo.Members rows whose Reference1 matches a datafeed CIN."""
        from airflow.models import Variable

        run_id = context["run_id"]
        raw_chunks = context["ti"].xcom_pull(task_ids="03_read_datafeed_files")
        member_references = set()
        for chunk in raw_chunks:
            raw_df = _read_frame(chunk["path"])
            cin_column = next(
                (
                    column
                    for column in ("CIN", "primary_member_reference")
                    if column in raw_df.columns
                ),
                None,
            )
            if cin_column is None:
                raise ValueError(
                    f"Datafeed file has no CIN column: {chunk['source_path']}"
                )
            member_references.update(
                raw_df[cin_column]
                .fillna("")
                .astype(str)
                .str.strip()
                .str.upper()
                .loc[lambda values: values.ne("")]
                .tolist()
            )

        target_table = os.environ.get(
            "HSBC_TARGET_TABLE",
            Variable.get("hsbc_target_table", default_var="dbo.Members"),
        )

        connection = _database_connection()
        try:
            target_df = read_target(
                connection,
                target_table,
                member_references=member_references,
            )
        finally:
            connection.close()

        path = _run_directory(run_id) / "dbo_members.pkl"
        return {
            "path": _write_frame(target_df, path),
            "rows": len(target_df),
            "feed_cins": len(member_references),
            "target_table": target_table,
        }

    def read_datafeed_files(**context) -> list:
        """Read local CSV files in bounded chunks and persist raw chunk artifacts."""
        from airflow.models import Variable

        run_id = context["run_id"]
        delimiter = os.environ.get(
            "HSBC_INPUT_DELIMITER",
            Variable.get("hsbc_input_delimiter", default_var=","),
        )
        source_files = sorted(path for path in DATAFEED_DIR.glob("*.csv") if path.is_file())
        if not source_files:
            raise ValueError(f"No CSV files found in {DATAFEED_DIR}")

        chunks = []
        run_directory = _run_directory(run_id)
        for source_path in source_files:
            source = _source_object(source_path)
            file_had_rows = False
            for chunk_number, raw_chunk in enumerate(
                pd.read_csv(
                    source_path,
                    sep=delimiter,
                    dtype=str,
                    keep_default_na=False,
                    chunksize=PANDAS_CHUNK_SIZE,
                ),
                start=1,
            ):
                file_had_rows = True
                first_row = ((chunk_number - 1) * PANDAS_CHUNK_SIZE) + 2
                raw_chunk["_source_row_number"] = range(first_row, first_row + len(raw_chunk))
                path = run_directory / source["file_id"] / f"raw-{chunk_number:06d}.pkl"
                chunks.append({
                    "path": _write_frame(raw_chunk, path),
                    "source_path": str(source_path),
                    "source": source,
                    "chunk_number": chunk_number,
                    "input_rows": len(raw_chunk),
                })
            if not file_had_rows:
                raise ValueError(f"Source file is empty: {source_path}")
        return chunks

    def validate_datafeed(**context) -> list:
        """Normalize and validate each raw datafeed chunk."""
        run_id = context["run_id"]
        raw_chunks = context["ti"].xcom_pull(task_ids="03_read_datafeed_files")
        validated_chunks = []
        run_directory = _run_directory(run_id)

        for chunk in raw_chunks:
            raw_df = _read_frame(chunk["path"])
            mapped = map_to_ten_standard(raw_df, chunk["source_path"], SCHEME_IDS)
            mapped["_source_row_number"] = raw_df["_source_row_number"].values
            require_unique_columns(mapped, TEN_STANDARD_COLUMNS, "Validation input")

            checked = run_dataframe_stage(
                "with_validation_errors_pandas",
                with_validation_errors_pandas,
                mapped,
            )
            valid, invalid = run_dataframe_stage(
                "split_valid_invalid_pandas",
                split_valid_invalid_pandas,
                checked,
            )
            valid, scheme_rejects = reject_unmapped_schemes(valid)
            rejects = pd.concat(
                [invalid, scheme_rejects],
                ignore_index=True,
                sort=False,
            )

            base = run_directory / chunk["source"]["file_id"]
            validated_chunks.append({
                **chunk,
                "valid_path": _write_frame(
                    coalesce_duplicate_columns(valid, "validated rows"),
                    base / f"valid-{chunk['chunk_number']:06d}.pkl",
                ),
                "validation_rejects_path": _write_frame(
                    coalesce_duplicate_columns(rejects, "validation rejects"),
                    base / f"validation-rejects-{chunk['chunk_number']:06d}.pkl",
                ),
            })
        return validated_chunks

    def check_new_data_against_db(**context) -> list:
        """Check conflicts and retain only new or changed dbo.Members rows."""
        run_id = context["run_id"]
        validated_chunks = context["ti"].xcom_pull(task_ids="04_validate_datafeed")
        members_snapshot = context["ti"].xcom_pull(task_ids="02_load_dbo_members")
        target_df = _read_frame(members_snapshot["path"])
        conflict_target = target_rows_for_email_conflicts(target_df)
        checked_chunks = []
        run_directory = _run_directory(run_id)

        for chunk in validated_chunks:
            valid = _read_frame(chunk["valid_path"])
            if valid.empty:
                accepted = valid.copy()
                email_conflicts = valid.copy()
                members = pd.DataFrame()
            else:
                accepted, email_conflicts = run_dataframe_stage(
                    "reject_email_conflicts_pandas",
                    reject_email_conflicts_pandas,
                    valid,
                    conflict_target,
                )
                all_members = run_dataframe_stage(
                    "build_members_model_pandas",
                    build_members_model_pandas,
                    accepted,
                    target_df,
                )
                all_members = coalesce_duplicate_columns(all_members, "Members model")
                all_members = all_members.drop_duplicates(["SchemeID", "Reference1"])
                members = run_dataframe_stage(
                    "filter_changed_pandas",
                    filter_changed_pandas,
                    all_members,
                    target_df,
                )

            base = run_directory / chunk["source"]["file_id"]
            conflict_reject_rows = len(email_conflicts)
            if conflict_reject_rows:
                conflict_rejects = add_reject_audit_fields(
                    email_conflicts,
                    chunk["source"],
                    chunk["chunk_number"],
                )
                conflict_reject_path = (
                    REJECT_DIR
                    / f"{Path(chunk['source_path']).stem}."
                    f"chunk-{chunk['chunk_number']:06d}.conflicts.csv"
                )
                REJECT_DIR.mkdir(parents=True, exist_ok=True)
                conflict_rejects.to_csv(conflict_reject_path, index=False)

            checked_chunks.append({
                **chunk,
                "members_path": _write_frame(
                    coalesce_duplicate_columns(members, "changed members"),
                    base / f"members-{chunk['chunk_number']:06d}.pkl",
                ),
                "database_rows_to_write": len(members),
                "conflict_reject_rows": conflict_reject_rows,
            })
        return checked_chunks

    def write_error_chunks(**context) -> dict:
        """Write validation rejects after datafeed validation."""
        validated_chunks = context["ti"].xcom_pull(task_ids="04_validate_datafeed")
        REJECT_DIR.mkdir(parents=True, exist_ok=True)
        reject_rows = 0

        for chunk in validated_chunks:
            rejects = _read_frame(chunk["validation_rejects_path"])
            if rejects.empty:
                continue

            rejects = add_reject_audit_fields(
                rejects,
                chunk["source"],
                chunk["chunk_number"],
            )
            reject_path = (
                REJECT_DIR
                / f"{Path(chunk['source_path']).stem}."
                f"chunk-{chunk['chunk_number']:06d}.rejects.csv"
            )
            rejects.to_csv(reject_path, index=False)
            reject_rows += len(rejects)

        return {"reject_rows": reject_rows}

    def load_new_data_to_db(**context) -> dict:
        """Load changed rows after all reject files have been written."""
        checked_chunks = context["ti"].xcom_pull(
            task_ids="06_check_new_data_against_db"
        )
        error_summary = context["ti"].xcom_pull(task_ids="05_write_error_chunks")
        members_snapshot = context["ti"].xcom_pull(task_ids="02_load_dbo_members")
        connection = _database_connection()
        written_rows = 0
        try:
            for chunk in checked_chunks:
                members = _read_frame(chunk["members_path"])
                write_to_members(connection, members, members_snapshot["target_table"])
                written_rows += len(members)
        finally:
            connection.close()

        return {
            "files": len({chunk["source"]["file_id"] for chunk in checked_chunks}),
            "chunks": len(checked_chunks),
            "input_rows": sum(chunk["input_rows"] for chunk in checked_chunks),
            "database_rows_written": written_rows,
            "reject_rows": (
                error_summary["reject_rows"]
                + sum(chunk["conflict_reject_rows"] for chunk in checked_chunks)
            ),
        }

    connect_to_db_task = PythonOperator(
        task_id="01_connect_to_db",
        python_callable=connect_to_db,
        dag=dag,
    )

    load_dbo_members_task = PythonOperator(
        task_id="02_load_dbo_members",
        python_callable=load_dbo_members,
        dag=dag,
    )

    read_datafeed_files_task = PythonOperator(
        task_id="03_read_datafeed_files",
        python_callable=read_datafeed_files,
        dag=dag,
    )

    validate_datafeed_task = PythonOperator(
        task_id="04_validate_datafeed",
        python_callable=validate_datafeed,
        dag=dag,
    )

    write_error_chunks_task = PythonOperator(
        task_id="05_write_error_chunks",
        python_callable=write_error_chunks,
        dag=dag,
    )

    check_new_data_against_db_task = PythonOperator(
        task_id="06_check_new_data_against_db",
        python_callable=check_new_data_against_db,
        dag=dag,
    )

    load_new_data_to_db_task = PythonOperator(
        task_id="07_load_new_data_to_db",
        python_callable=load_new_data_to_db,
        dag=dag,
    )

    connect_to_db_task >> read_datafeed_files_task
    read_datafeed_files_task >> [
        load_dbo_members_task,
        validate_datafeed_task,
    ]
    validate_datafeed_task >> [
        write_error_chunks_task,
        check_new_data_against_db_task,
    ]
    load_dbo_members_task >> check_new_data_against_db_task
    [
        write_error_chunks_task,
        check_new_data_against_db_task,
    ] >> load_new_data_to_db_task
