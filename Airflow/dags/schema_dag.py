"""Create HSBC datafeed schema objects in SQL Server."""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from sql_etl import CONNECTION_ID, run_schema_script, schema_scripts, verify_schema_tables


def verify_schema_tables_without_datafeed_errors() -> dict:
    return verify_schema_tables(
        include_datafeed_errors=False,
        connection_id=CONNECTION_ID,
    )


with DAG(
    dag_id="create_hsbc_schema",
    schedule_interval=None,
    start_date=datetime(2026, 6, 21),
    catchup=False,
    default_args={
        "owner": "data-eng",
        "retries": 0,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["hsbc", "schema", "mssql"],
) as dag:
    previous_task = None

    for index, script_path in enumerate(
        schema_scripts(include_datafeed_errors=False),
        start=1,
    ):
        task = PythonOperator(
            task_id=f"{index:02d}_{script_path.stem.lower()}",
            python_callable=run_schema_script,
            op_kwargs={
                "script_name": script_path.name,
                "connection_id": CONNECTION_ID,
            },
        )

        if previous_task is not None:
            previous_task >> task
        previous_task = task

    verify_schema_tables_task = PythonOperator(
        task_id="verify_schema_tables",
        python_callable=verify_schema_tables_without_datafeed_errors,
    )

    previous_task >> verify_schema_tables_task
