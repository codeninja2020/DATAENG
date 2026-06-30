import csv
import os
from datetime import datetime
from pathlib import Path

from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.operators.python import PythonOperator

server = os.environ.get("server")
username = os.environ.get("username")
password = os.environ.get("password")
database = os.environ.get("database")

default_args = {
    "owner": "data-eng",
}


def store_rpin_errors():
    """Stores the RPIN errors from the SQL query into a CSV file."""
    from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook

    dags_directory = Path(__file__).resolve().parent
    sql_path = dags_directory / "sql" / "check_rpin.sql"
    output_path = dags_directory / "dags_data_quality" / "errors" / "rpin_errors.csv"

    query = sql_path.read_text(encoding="utf-8")
    hook = MsSqlHook(mssql_conn_id="mssql_default")

    with hook.get_conn() as connection:
        cursor = connection.cursor()
        cursor.execute(query)
        rows = cursor.fetchall()
        column_names = [column[0] for column in cursor.description]

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", newline="", encoding="utf-8") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(column_names)
        writer.writerows(rows)

    return str(output_path)


with DAG(
    dag_id="data_quality_checks",
    schedule_interval='0 14 * * *',# Run at 14:00 UTC (2:00 PM) every day
    start_date=datetime(2026, 6, 21),
    tags=['sql','data_quality'],
    catchup=False,
    default_args=default_args,
) as dag:

    # Example of creating a task to create a table in MsSql

    read_table_mssql_task = SQLExecuteQueryOperator(
        task_id='view_db_tables',
        conn_id="mssql_default",
        sql="sql/example_script.sql",
        dag=dag,
    )

    data_quality_task = SQLExecuteQueryOperator(
        task_id='data_quality_check',
        conn_id="mssql_default",
        sql="sql/validation_report.sql",
        dag=dag,
    )

    data_quality_details_task = SQLExecuteQueryOperator(
        task_id='data_quality_details',
        conn_id="mssql_default",
        sql="sql/validation_detail.sql",
        dag=dag,
    )

    data_quality_rpin_task = SQLExecuteQueryOperator(
        task_id='data_quality_rpin',
        conn_id="mssql_default",
        sql="sql/check_rpin.sql",
        dag=dag,
    )

    """ Store the RPIN errors from the SQL query into a CSV file. This task will be executed after the data_quality_rpin_task. """
    store_rpin_errors_task = PythonOperator(
        task_id="store_rpin_errors",
        python_callable=store_rpin_errors,
        dag=dag,
    )

    read_table_mssql_task >> data_quality_task >> data_quality_details_task
    read_table_mssql_task >> data_quality_rpin_task >> store_rpin_errors_task

       
    
