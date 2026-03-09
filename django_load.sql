/* ============================================================================
   Django load (SSIS replacement)
   Follows the cms_load.sql pattern to replace the Django_Import SSIS project.
   Steps:
     1) Download all Django CSVs from S3 to D:\S3\BE_DJANGO_POSTGRES_CSV\
     2) Ensure the django schema exists and truncate destination tables
     3) For each entity, stage raw data, convert to destination types, append
        audit columns, and load into TenDataWarehouse.django.{table}
     4) Delete the downloaded CSV files from the local drive

   Source: s3://bi-prod.tenproduct.com/BE_DJANGO_POSTGRES_CSV/{entity}.csv
   Format: pipe-delimited, UTF-8, header row, LF line endings
   Dest DB / schema: TenDataWarehouse.django
============================================================================ */

SET NOCOUNT ON;
SET XACT_ABORT ON;

USE msdb;

DECLARE @S3Bucket  NVARCHAR(200) = N'bi-prod.tenproduct.com';
DECLARE @S3Prefix  NVARCHAR(200) = N'BE_DJANGO_POSTGRES_CSV';
DECLARE @LocalRoot NVARCHAR(200) = N'D:\S3\BE_DJANGO_POSTGRES_CSV';
DECLARE @PollDelay CHAR(8)       = '00:00:03';

-- Entity list from the Django_Import SSIS project
DECLARE @Entities TABLE (Id INT IDENTITY(1,1), Entity NVARCHAR(128));
INSERT INTO @Entities (Entity) VALUES
    (N'articles'),
    (N'brands'),
    (N'dining_celebrity_chefs'),
    (N'dining_cuisine'),
    (N'dining_hot_table_bookings'),
    (N'dining_hot_tables'),
    (N'dining_restaurant_benefits'),
    (N'dining_restaurants'),
    (N'email_templates'),
    (N'entertainment_artists'),
    (N'entertainment_bookings'),
    (N'entertainment_delivery_methods'),
    (N'entertainment_event_tags'),
    (N'entertainment_events'),
    (N'entertainment_performances'),
    (N'entertainment_ticket_types'),
    (N'entertainment_venues'),
    (N'interest_id_entertainment_events'),
    (N'jobs'),
    (N'location_cities'),
    (N'location_countries'),
    (N'location_locationtags'),
    (N'member_benefit_memberbenefit_sites'),
    (N'member_benefit_memberbenefit_tags'),
    (N'member_benefits'),
    (N'member_details'),
    (N'member_events'),
    (N'member_events_bookings'),
    (N'member_events_dates'),
    (N'member_events_memberevent'),
    (N'member_events_memberevent_tags'),
    (N'member_profiles'),
    (N'partners'),
    (N'sites'),
    (N'tags'),
    (N'travel_airport_groups'),
    (N'travel_airports'),
    (N'travel_car_hire_depots'),
    (N'travel_hotels');

DECLARE @EntityCount INT = (SELECT MAX(Id) FROM @Entities);

PRINT 'Downloading ' + CAST(@EntityCount AS VARCHAR) + ' Django CSV files from S3...';

DECLARE @i INT = 1;
DECLARE @entity NVARCHAR(128);
DECLARE @s3Arn NVARCHAR(500);
DECLARE @localPath NVARCHAR(500);
DECLARE @taskId INT;
DECLARE @status NVARCHAR(50);

WHILE @i <= @EntityCount
BEGIN
    SELECT @entity = Entity FROM @Entities WHERE Id = @i;

    SET @s3Arn     = N'arn:aws:s3:::' + @S3Bucket + N'/' + @S3Prefix + N'/' + @entity + N'.csv';
    SET @localPath = @LocalRoot + N'\' + @entity + N'.csv';

    PRINT '  Downloading ' + @entity + '.csv ...';

    EXEC msdb.dbo.rds_download_from_s3
        @s3_arn_of_file  = @s3Arn,
        @rds_file_path   = @localPath,
        @overwrite_file  = 1;

    SELECT TOP 1 @taskId = task_id
    FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
    WHERE task_type IN ('DOWNLOAD_FROM_S3','DOWNLOAD_FROM_S3')
    ORDER BY task_id DESC;

    IF @taskId IS NULL
        RAISERROR('Could not find task_id for %s download.', 16, 1, @entity);

    SET @status = N'IN_PROGRESS';
    WHILE @status IN (N'CREATED', N'IN_PROGRESS')
    BEGIN
        WAITFOR DELAY @PollDelay;
        SELECT @status = lifecycle
        FROM msdb.dbo.rds_fn_task_status(NULL, @taskId);
    END

    IF @status <> N'SUCCESS'
        RAISERROR('S3 download failed for %s (task %d, status %s)', 16, 1, @entity, @taskId, @status);

    PRINT '    Completed ' + @entity + '.csv (task ' + CAST(@taskId AS VARCHAR(20)) + ').';
    SET @i += 1;
END

PRINT 'Downloads complete. Loading into TenDataWarehouse...';

USE TenDataWarehouse;

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'django')
    EXEC('CREATE SCHEMA django AUTHORIZATION dbo');

DECLARE @ProcessId VARCHAR(36) = CONVERT(CHAR(36), NEWID());
SET @i = 1;

WHILE @i <= @EntityCount
BEGIN
    SELECT @entity = Entity FROM @Entities WHERE Id = @i;
    SET @localPath = @LocalRoot + N'\' + @entity + N'.csv';

    PRINT 'Loading django.' + @entity;

    IF OBJECT_ID(N'django.' + @entity, N'U') IS NULL
    BEGIN
        PRINT '  Skipped: table not found.';
        SET @i += 1;
        CONTINUE;
    END

    DECLARE @DataCols NVARCHAR(MAX);
    DECLARE @InsertCols NVARCHAR(MAX);
    DECLARE @SelectCols NVARCHAR(MAX);
    DECLARE @InsertedOnCol NVARCHAR(200);
    DECLARE @ProcessIdCol NVARCHAR(200);
    DECLARE @FileNameCol NVARCHAR(200);
    DECLARE @HasIdentity BIT = 0;

    SELECT @DataCols = STRING_AGG(QUOTENAME(c.name), ', ') WITHIN GROUP (ORDER BY c.column_id)
    FROM sys.columns c
    JOIN sys.tables t   ON t.object_id = c.object_id
    JOIN sys.schemas s  ON s.schema_id = t.schema_id
    WHERE s.name = N'django'
      AND t.name = @entity
      AND c.is_computed = 0
      AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

    IF @DataCols IS NULL
    BEGIN
        PRINT '  Skipped: no loadable (non-audit) columns found.';
        SET @i += 1;
        CONTINUE;
    END

    SELECT @InsertCols = STRING_AGG(QUOTENAME(c.name), ', ') WITHIN GROUP (ORDER BY c.column_id),
           @SelectCols = STRING_AGG(
               'TRY_CONVERT(' +
               CASE
                   WHEN tt.name IN ('varchar','char') THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
                   WHEN tt.name IN ('nvarchar','nchar') THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length/2 AS VARCHAR(10)) END + ')'
                   WHEN tt.name IN ('varbinary','binary') THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
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
      AND t.name = @entity
      AND c.is_computed = 0
      AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

    SELECT @InsertedOnCol = QUOTENAME(c.name)
    FROM sys.columns c
    JOIN sys.tables t  ON t.object_id = c.object_id
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = N'django'
      AND t.name = @entity
      AND LOWER(c.name) = 'inserted_on';

    SELECT @ProcessIdCol = QUOTENAME(c.name)
    FROM sys.columns c
    JOIN sys.tables t  ON t.object_id = c.object_id
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = N'django'
      AND t.name = @entity
      AND LOWER(c.name) = 'processid';

    SELECT @FileNameCol = QUOTENAME(c.name)
    FROM sys.columns c
    JOIN sys.tables t  ON t.object_id = c.object_id
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = N'django'
      AND t.name = @entity
      AND LOWER(c.name) = 'filename';

    SELECT TOP 1 @HasIdentity = 1
    FROM sys.columns c
    JOIN sys.tables t  ON t.object_id = c.object_id
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = N'django'
      AND t.name = @entity
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

    DECLARE @RawCols NVARCHAR(MAX);
    DECLARE @CreateRaw NVARCHAR(MAX);

    SELECT @RawCols = STRING_AGG('    ' + QUOTENAME(c.name) + ' NVARCHAR(4000)', ',' + CHAR(13) + CHAR(10))
    FROM sys.columns c
    JOIN sys.tables t   ON t.object_id = c.object_id
    JOIN sys.schemas s  ON s.schema_id = t.schema_id
    WHERE s.name = N'django'
      AND t.name = @entity
      AND c.is_computed = 0
      AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

    SET @CreateRaw = N'
IF OBJECT_ID(''tempdb..#RawData'') IS NOT NULL DROP TABLE #RawData;
CREATE TABLE #RawData (
' + @RawCols + '
);';

    BEGIN TRY
        EXEC(@CreateRaw);

        EXEC(N'BULK INSERT #RawData
              FROM ''' + @localPath + '''
              WITH (
                  FIELDTERMINATOR = ''|'',
                  ROWTERMINATOR   = ''0x0A'',
                  FIRSTROW        = 2,
                  CODEPAGE        = ''65001'',
                  TABLOCK
              );');

        DECLARE @insertSql NVARCHAR(MAX) = N'TRUNCATE TABLE django.' + QUOTENAME(@entity) + ';
' +
            CASE WHEN @HasIdentity = 1
                 THEN N'SET IDENTITY_INSERT django.' + QUOTENAME(@entity) + ' ON;
'
                 ELSE N'' END +
            N'INSERT INTO django.' + QUOTENAME(@entity) + '(' + @InsertCols + ')
              SELECT ' + @SelectCols + ' FROM #RawData;
' +
            CASE WHEN @HasIdentity = 1
                 THEN N'SET IDENTITY_INSERT django.' + QUOTENAME(@entity) + ' OFF;
'
                 ELSE N'' END;

        EXEC sp_executesql
            @insertSql,
            N'@pid VARCHAR(36), @fileName NVARCHAR(260)',
            @pid = @ProcessId,
            @fileName = @entity + N'.csv';

        EXEC('DROP TABLE #RawData;');
        PRINT '  Loaded ' + @entity;
    END TRY
    BEGIN CATCH
        PRINT '  Error loading ' + @entity + ': ' + ERROR_MESSAGE();
        IF OBJECT_ID('tempdb..#RawData') IS NOT NULL DROP TABLE #RawData;
    END CATCH

    SET @i += 1;
END

USE msdb;
PRINT 'Deleting downloaded CSVs...';

SET @i = 1;
WHILE @i <= @EntityCount
BEGIN
    SELECT @entity = Entity FROM @Entities WHERE Id = @i;
    SET @localPath = @LocalRoot + N'\' + @entity + N'.csv';

    BEGIN TRY
        EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = @localPath;
    END TRY
    BEGIN CATCH
        PRINT '  Warning: could not delete ' + @localPath + ': ' + ERROR_MESSAGE();
    END CATCH

    SET @i += 1;
END

PRINT 'Django load complete. ProcessId: ' + @ProcessId;
