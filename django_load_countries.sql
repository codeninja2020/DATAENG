/* ============================================================================
   Django single-entity loader: location_countries
   Source: s3://bi-staging.tenproduct.com/BE_DJANGO_POSTGRES_CSV/TP_20260209220038/location_countries.csv
   Target: TenDataWarehouse.django.location_countries
   Pattern: same staged/raw → typed insert → audit columns as cms_load.sql
============================================================================ */
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ── Download from S3 to local filesystem ──
USE msdb;

DECLARE @S3Arn     NVARCHAR(500) = N'arn:aws:s3:::bi-staging.tenproduct.com/BE_DJANGO_POSTGRES_CSV/TP_20260209220038/location_countries.csv';
DECLARE @LocalPath NVARCHAR(500) = N'D:\S3\BE_DJANGO_POSTGRES_CSV\TP_20260209220038\location_countries.csv';
DECLARE @PollDelay CHAR(8)       = '00:00:03';
DECLARE @taskId    INT;
DECLARE @status    NVARCHAR(50);

PRINT 'Downloading location_countries.csv from S3...';

EXEC msdb.dbo.rds_download_from_s3
    @s3_arn_of_file  = @S3Arn,
    @rds_file_path   = @LocalPath,
    @overwrite_file  = 1;

SELECT TOP 1 @taskId = task_id
FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
WHERE task_type IN ('DOWNLOAD_FROM_S3','DOWNLOAD_FROM_S3')
ORDER BY task_id DESC;

IF @taskId IS NULL
    RAISERROR('Could not find download task for location_countries.csv', 16, 1);

SET @status = N'IN_PROGRESS';
WHILE @status IN (N'CREATED', N'IN_PROGRESS')
BEGIN
    WAITFOR DELAY @PollDelay;
    SELECT @status = lifecycle
    FROM msdb.dbo.rds_fn_task_status(NULL, @taskId);
END

IF @status <> N'SUCCESS'
    RAISERROR('S3 download failed for location_countries.csv (task %d, status %s)', 16, 1, @taskId, @status);

PRINT 'Download complete (task ' + CAST(@taskId AS VARCHAR(20)) + ').';

-- ── Load into TenDataWarehouse ──
USE TenDataWarehouse;

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'django')
    EXEC('CREATE SCHEMA django AUTHORIZATION dbo');

IF OBJECT_ID(N'django.location_countries', N'U') IS NULL
    RAISERROR('Target table django.location_countries does not exist.', 16, 1);

DECLARE @ProcessId VARCHAR(36) = CONVERT(CHAR(36), NEWID());

DECLARE @InsertCols NVARCHAR(MAX);
DECLARE @SelectCols NVARCHAR(MAX);
DECLARE @DataCols   NVARCHAR(MAX);
DECLARE @RawCols    NVARCHAR(MAX);
DECLARE @InsertedOnCol NVARCHAR(200);
DECLARE @ProcessIdCol NVARCHAR(200);
DECLARE @FileNameCol NVARCHAR(200);
DECLARE @HasIdentity BIT = 0;
DECLARE @FieldTerm NVARCHAR(5) = '|';
DECLARE @RowTerm NVARCHAR(10) = '0x0A';

SELECT @DataCols = STRING_AGG(QUOTENAME(c.name), ', ') WITHIN GROUP (ORDER BY c.column_id)
FROM sys.columns c
JOIN sys.tables t   ON t.object_id = c.object_id
JOIN sys.schemas s  ON s.schema_id = t.schema_id
WHERE s.name = N'django'
  AND t.name = N'location_countries'
  AND c.is_computed = 0
  AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

IF @DataCols IS NULL
    RAISERROR('No loadable columns found on django.location_countries.', 16, 1);

SELECT @InsertCols = STRING_AGG(QUOTENAME(c.name), ', ') WITHIN GROUP (ORDER BY c.column_id),
       @SelectCols = STRING_AGG(
           'TRY_CONVERT(' +
           CASE
               WHEN tt.name IN ('varchar','char','varbinary','binary') THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
               WHEN tt.name IN ('nvarchar','nchar') THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length/2 AS VARCHAR(10)) END + ')'
               WHEN tt.name IN ('decimal','numeric') THEN tt.name + '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
               WHEN tt.name IN ('datetime2','datetimeoffset','time') THEN tt.name + '(' + CAST(c.scale AS VARCHAR(10)) + ')'
               ELSE tt.name
           END + ', NULLIF(' + QUOTENAME(c.name) + ', ''''))'
       , ', ') WITHIN GROUP (ORDER BY c.column_id)
FROM sys.columns c
JOIN sys.tables t   ON t.object_id = c.object_id
JOIN sys.schemas s  ON s.schema_id = t.schema_id
JOIN sys.types tt   ON tt.user_type_id = c.user_type_id
WHERE s.name = N'django'
  AND t.name = N'location_countries'
  AND c.is_computed = 0
  AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

SELECT @InsertedOnCol = QUOTENAME(c.name)
FROM sys.columns c
JOIN sys.tables t  ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = N'django'
  AND t.name = N'location_countries'
  AND LOWER(c.name) = 'inserted_on';

SELECT @ProcessIdCol = QUOTENAME(c.name)
FROM sys.columns c
JOIN sys.tables t  ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = N'django'
  AND t.name = N'location_countries'
  AND LOWER(c.name) = 'processid';

SELECT @FileNameCol = QUOTENAME(c.name)
FROM sys.columns c
JOIN sys.tables t  ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = N'django'
  AND t.name = N'location_countries'
  AND LOWER(c.name) = 'filename';

SELECT TOP 1 @HasIdentity = 1
FROM sys.columns c
JOIN sys.tables t  ON t.object_id = c.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = N'django'
  AND t.name = N'location_countries'
  AND LOWER(c.name) NOT IN ('inserted_on','processid','filename')
  AND c.is_identity = 1;

IF @InsertedOnCol IS NOT NULL
BEGIN
    SET @InsertCols = @InsertCols + ', ' + @InsertedOnCol;
    SET @SelectCols = @SelectCols + ', GETDATE()';
END
IF @ProcessIdCol IS NOT NULL
BEGIN
    SET @InsertCols = @InsertCols + ', ' + @ProcessIdCol;
    SET @SelectCols = @SelectCols + ', @pid';
END
IF @FileNameCol IS NOT NULL
BEGIN
    SET @InsertCols = @InsertCols + ', ' + @FileNameCol;
    SET @SelectCols = @SelectCols + ', @fileName';
END

SELECT @RawCols = STRING_AGG('    ' + QUOTENAME(c.name) + ' NVARCHAR(4000)', ',' + CHAR(13) + CHAR(10))
FROM sys.columns c
JOIN sys.tables t   ON t.object_id = c.object_id
JOIN sys.schemas s  ON s.schema_id = t.schema_id
WHERE s.name = N'django'
  AND t.name = N'location_countries'
  AND c.is_computed = 0
  AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

DECLARE @CreateRaw NVARCHAR(MAX) = N'
IF OBJECT_ID(''tempdb..#RawData'') IS NOT NULL DROP TABLE #RawData;
CREATE TABLE #RawData (
' + @RawCols + '
);';

BEGIN TRY
    EXEC(@CreateRaw);

    EXEC(N'BULK INSERT #RawData
          FROM ''' + @LocalPath + '''
          WITH (
              FIELDTERMINATOR = ' + QUOTENAME(@FieldTerm, '''') + ',
              ROWTERMINATOR   = ' + QUOTENAME(@RowTerm, '''') + ',
              FIRSTROW        = 2,
              CODEPAGE        = ''65001'',
              TABLOCK
          );');

    DECLARE @insertSql NVARCHAR(MAX) = N'TRUNCATE TABLE django.location_countries;
' +
        CASE WHEN @HasIdentity = 1
             THEN N'SET IDENTITY_INSERT django.location_countries ON;
'
             ELSE N'' END +
        N'INSERT INTO django.location_countries(' + @InsertCols + ')
          SELECT ' + @SelectCols + ' FROM #RawData;
' +
        CASE WHEN @HasIdentity = 1
             THEN N'SET IDENTITY_INSERT django.location_countries OFF;
'
             ELSE N'' END;

    EXEC sp_executesql
        @insertSql,
        N'@pid VARCHAR(36), @fileName NVARCHAR(260)',
        @pid = @ProcessId,
        @fileName = N'location_countries.csv';

    EXEC('DROP TABLE #RawData;');
    PRINT 'Loaded django.location_countries (ProcessId: ' + @ProcessId + ').';
END TRY
BEGIN CATCH
    PRINT 'Error loading django.location_countries: ' + ERROR_MESSAGE();
    IF OBJECT_ID('tempdb..#RawData') IS NOT NULL DROP TABLE #RawData;
    THROW;
END CATCH

-- ── Clean up local file ──
USE msdb;
BEGIN TRY
    EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = @LocalPath;
END TRY
BEGIN CATCH
    PRINT 'Warning: could not delete ' + @LocalPath + ': ' + ERROR_MESSAGE();
END CATCH
