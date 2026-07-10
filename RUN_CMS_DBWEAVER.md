# Run `CMS.sql` in DB Weaver (SQL Server)

Use these steps to create and run the SQL Agent job from DB Weaver.

## 1) Connect to the correct SQL Server instance
- Open DB Weaver and connect to the SQL Server that hosts `msdb` and `TEN_DATAWAREHOUSE`.
- Use a login with permission to:
  - create/update SQL Agent jobs in `msdb`
  - create/truncate/insert into `TEN_DATAWAREHOUSE.dbo` tables

## 2) Open and execute the script
1. Open `CMS.sql` in a SQL Server SQL Editor tab.
2. Make sure the script is executed as a **script** (not just a single statement), because it uses `GO` batch separators.
3. Run the whole file.

> Important: the script itself checks `IF DB_NAME() <> 'msdb' THROW ...`, so start from `msdb` context (or run as script so that check passes when intended).

## 3) Validate that the SQL Agent job was created
Run this query:

```sql
USE msdb;
GO
SELECT name, enabled
FROM dbo.sysjobs
WHERE name = N'CMS_S3_Import';
```

## 4) Run the job manually the first time
```sql
USE msdb;
GO
EXEC dbo.sp_start_job @job_name = N'CMS_S3_Import';
```

## 5) Check job execution status/history
```sql
USE msdb;
GO
EXEC dbo.sp_help_jobhistory @job_name = N'CMS_S3_Import';
```

## 6) Validate rows loaded into destination tables
```sql
USE TEN_DATAWAREHOUSE;
GO
SELECT COUNT(*) AS DiningCount    FROM dbo.Dining;
SELECT COUNT(*) AS HotelsCount    FROM dbo.Hotels;
SELECT COUNT(*) AS LocationsCount FROM dbo.Locations;
```

## Common issues
- **`Must run in msdb` error**: switch context to `msdb` and rerun as full script.
- **S3 download failures**: confirm RDS SQL Server has access to `arn:aws:s3:::bi-staging.tenproduct.com/CMS/...` and filenames match exactly (`Dining.csv`, `Hotels.csv`, `Travel_Location.csv`).
- **`BULK INSERT` file/path errors**: ensure RDS task finished successfully and file paths are accessible as `D:\S3\CMS\...`.
