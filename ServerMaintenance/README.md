# Django S3 Loader (dhango_agent_jobscript13.sql)

This script replaces the legacy SSIS Django_Import packages. It downloads Django CSVs from S3 to the RDS host, stages them into temporary tables, converts to target types, adds audit columns, and loads into `TenDataWarehouse.django.*`. It also tracks download/load status.

## Prerequisites
- Run in `TenDataWarehouse` on the RDS instance that has the AWS RDS helper procs (`msdb.dbo.rds_download_from_s3`, `msdb.dbo.rds_fn_task_status`, `msdb.dbo.rds_delete_from_filesystem`).
- The local folder on the RDS host must exist: `D:\S3\BE_DJANGO_POSTGRES_CSV\TP_20260209220038\`.
- S3 path: `arn:aws:s3:::bi-staging.tenproduct.com/BE_DJANGO_POSTGRES_CSV/TP_20260209220038/{file}.csv`.
- Target tables already exist under `django` schema (columns match the CSV headers; audit columns `inserted_on`, `processid`, `filename` are optional).

## What the script does
1) Ensures `django` schema and two tracking tables exist:
   - `django.S3_Download_Tracking`
   - `django.S3_Load_Tracking`
2) Procedure `django.usp_Download_And_Load_S3_Files`:
   - Builds a manifest of 36 CSVs (update list if needed).
   - For each file: downloads from S3 to the local path, records `task_id/lifecycle/task_info`.
   - Polls `rds_fn_task_status` until each download is finished; records final lifecycle/task_info.
   - For successful downloads: stages raw data into `#RawData` (all NVARCHAR), BULK INSERTs, truncates the target table, inserts with `TRY_CONVERT` to destination types, sets audit columns if present, handles identity insert when needed, and deletes the local file.
   - Populates `django.S3_Load_Tracking` with status, row counts, and errors.

## How to run
1) Open a query window in SSMS connected to the RDS instance.
2) Ensure the local folder exists on the RDS host: `D:\S3\BE_DJANGO_POSTGRES_CSV\TP_20260209220038\`.
3) Execute the contents of `dhango_agent_jobscript13.sql` (located at `/Users/tinashejambo/PycharmProjects/DATAENG/dhango_agent_jobscript13.sql`).
4) Run the procedure:
   ```sql
   USE TenDataWarehouse;
   EXEC django.usp_Download_And_Load_S3_Files;
   ```
5) Monitor download status:
   ```sql
   SELECT * FROM django.S3_Download_Tracking ORDER BY id DESC;
   SELECT TOP 20 task_id, lifecycle, task_info
   FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
   WHERE task_type = 'DOWNLOAD_FROM_S3'
   ORDER BY task_id DESC;
   ```
6) Monitor load status:
   ```sql
   SELECT * FROM django.S3_Load_Tracking ORDER BY id DESC;
   ```

## Adjustments
- Change S3 folder/version: update `@baseS3Prefix` and `@baseLocalPrefix` in the script.
- Limit to fewer files: edit the manifest in the `@files` table.
- Different delimiter/line ending: adjust `@FieldTerm` and `@RowTerm` variables in the load block.
- If a target table is missing, the load for that file fails and the error is recorded in `S3_Load_Tracking`.
