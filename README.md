# Django S3 Loader (dhango_agent_jobscript13.sql)

This script replaces the legacy SSIS Django_Import packages. It downloads Django CSVs from S3 to the RDS host (or uses local copies), stages them into temporary tables, converts to target types, adds audit columns, and loads into `TenDataWarehouse.django.*`. It also tracks download/load status and can auto-create destination tables based on the known CSV headers in `TP_20260209220038`.

## Prerequisites
- Run in `TenDataWarehouse` on the RDS instance that has the AWS RDS helper procs (`msdb.dbo.rds_download_from_s3`, `msdb.dbo.rds_fn_task_status`, `msdb.dbo.rds_delete_from_filesystem`).
- Ensure the local folder exists on the RDS host (or adjust the script): `D:\S3\BE_DJANGO_POSTGRES_CSV\TP_20260209220038\`.
- S3 path (if downloading): `arn:aws:s3:::bi-staging.tenproduct.com/BE_DJANGO_POSTGRES_CSV/TP_20260209220038/{file}.csv`.
- Target DB/schema: `TenDataWarehouse.django`. The script now auto-creates tables with typed columns based on the CSV headers from `TP_20260209220038`.

## What the script does
1) Ensures `django` schema and two tracking tables exist:
   - `django.S3_Download_Tracking`
   - `django.S3_Load_Tracking`
2) Creates all `django.*` destination tables (typed) from the headers found in the local folder `TP_20260209220038`.
3) Procedure `django.usp_Download_And_Load_S3_Files`:
   - Builds a manifest of the Django CSVs.
   - For each file: downloads from S3 to the local path (or uses the existing local copy), records `task_id/lifecycle/task_info`.
   - Polls `rds_fn_task_status` until each download is finished; records final lifecycle/task_info.
   - For successful downloads: stages raw data into `#RawData`, BULK INSERTs, truncates the target table, inserts with `TRY_CONVERT` to destination types, sets audit columns if present, handles identity insert when needed, and deletes the local file.
   - Populates `django.S3_Load_Tracking` with status, row counts, and errors.

## How to run
1) Open a query window in SSMS connected to the RDS instance.
2) Ensure the local folder exists on the RDS host: `D:\S3\BE_DJANGO_POSTGRES_CSV\TP_20260209220038\` (or adjust `@baseLocalPrefix` in the script).
3) Execute the contents of `dhango_agent_jobscript13.sql` (path: `/Users/tinashejambo/PycharmProjects/DATAENG/dhango_agent_jobscript13.sql`).
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
- If a target table is missing at runtime, the script will create it using the typed DDL embedded from `TP_20260209220038` headers (audits included).

## Troubleshooting: `No SSIS_tableConfig setup db` (legacy TenGroup/SSIS error)
If you see an error like **"Loader No SSIS_tableConfig setup db"**, you're usually running an old loader path that expects a legacy config table (`SSIS_tableConfig`) that is not present.

Use this checklist:

1. **Confirm you are in the correct database context.**
   ```sql
   SELECT DB_NAME() AS current_db;
   -- Expected: TenDataWarehouse (or TEN_DATAWAREHOUSE, depending on naming)
   ```

2. **Run the modern setup script first.**
   Execute `dhango_agent_jobscript13.sql` in full before calling the proc. This script creates the required `django` schema, tracking tables, and destination tables, and it does **not** require `SSIS_tableConfig`.

3. **Run the new procedure (not the old SSIS orchestration).**
   ```sql
   EXEC django.usp_Download_And_Load_S3_Files;
   ```

4. **Validate required objects exist.**
   ```sql
   SELECT OBJECT_ID('django.usp_Download_And_Load_S3_Files','P') AS proc_id,
          OBJECT_ID('django.S3_Download_Tracking','U')          AS download_tracking_id,
          OBJECT_ID('django.S3_Load_Tracking','U')              AS load_tracking_id;
   ```

5. **If you must run legacy SSIS code**, create/populate `SSIS_tableConfig` per that legacy package's expectations, or migrate that job step to use `django.usp_Download_And_Load_S3_Files`.

For direct troubleshooting against the legacy stored procedure, run `TenGroupFileLoader_diagnostic.sql`.
