"""Create HSBC SQL ETL schema objects and load the local datafeed."""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator

from sql_etl import (
    CONNECTION_ID,
    load_local_datafeed_to_raw,
    run_schema_script,
    run_stored_procedure_script,
    run_validate_and_load,
    schema_scripts,
    stored_procedure_scripts,
    verify_schema_tables,
)


with DAG(
    dag_id="run_hsbc_sql_etl",
    schedule_interval=None,
    start_date=datetime(2026, 6, 21),
    catchup=False,
    default_args={
        "owner": "data-eng",
        "retries": 0,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["hsbc", "sql-etl", "mssql"],
) as dag:
    previous_task = None

    for index, script_path in enumerate(schema_scripts(), start=1):
        task = PythonOperator(
            task_id=f"{index:02d}_schema_{script_path.stem.lower()}",
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
        python_callable=verify_schema_tables,
        op_kwargs={"connection_id": CONNECTION_ID},
    )

    previous_task >> verify_schema_tables_task
    previous_task = verify_schema_tables_task

    for index, script_path in enumerate(stored_procedure_scripts(), start=1):
        task = PythonOperator(
            task_id=f"{index:02d}_procedure_{script_path.stem.lower()}",
            python_callable=run_stored_procedure_script,
            op_kwargs={
                "script_name": script_path.name,
                "connection_id": CONNECTION_ID,
            },
        )

        if previous_task is not None:
            previous_task >> task
        previous_task = task

    load_local_datafeed_task = PythonOperator(
        task_id="load_local_datafeed_to_raw",
        python_callable=load_local_datafeed_to_raw,
        op_kwargs={"connection_id": CONNECTION_ID},
    )

    validate_and_load_task = PythonOperator(
        task_id="validate_and_load_tempmembers",
        python_callable=run_validate_and_load,
        op_kwargs={"connection_id": CONNECTION_ID},
    )

    previous_task >> load_local_datafeed_task >> validate_and_load_task
