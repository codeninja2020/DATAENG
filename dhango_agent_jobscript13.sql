USE TEN_DATAWAREHOUSE;

/*1.TRACKING TABLES*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'django')
    EXEC('CREATE SCHEMA django AUTHORIZATION dbo'); -- create db schema

IF OBJECT_ID('django.S3_Download_Tracking', 'U') IS NULL
BEGIN
    CREATE TABLE django.S3_Download_Tracking
    (
        id               INT IDENTITY(1,1) PRIMARY KEY,
        run_id           UNIQUEIDENTIFIER NOT NULL,
        file_name        NVARCHAR(200) NOT NULL,
        target_schema    SYSNAME NOT NULL,
        target_table     SYSNAME NOT NULL,
        s3_path          NVARCHAR(500) NOT NULL,
        local_path       NVARCHAR(500) NOT NULL,
        task_id          INT NULL,
        submitted_at     DATETIME NOT NULL DEFAULT GETDATE(),
        completed_at     DATETIME NULL,
        lifecycle        VARCHAR(50) NULL,
        task_info        NVARCHAR(MAX) NULL
    );
END;

IF OBJECT_ID('django.S3_Load_Tracking', 'U') IS NULL
BEGIN
    CREATE TABLE django.S3_Load_Tracking
    (
        id               INT IDENTITY(1,1) PRIMARY KEY,
        run_id           UNIQUEIDENTIFIER NOT NULL,
        file_name        NVARCHAR(200) NOT NULL,
        target_schema    SYSNAME NOT NULL,
        target_table     SYSNAME NOT NULL,
        local_path       NVARCHAR(500) NOT NULL,
        process_id       UNIQUEIDENTIFIER NULL,
        status           VARCHAR(50) NOT NULL,
        rows_inserted    INT NULL,
        error_message    NVARCHAR(MAX) NULL,
        started_at       DATETIME NOT NULL DEFAULT GETDATE(),
        finished_at      DATETIME NULL
    );
END;


/*2. MAIN PROCEDURE*/
CREATE OR ALTER PROCEDURE django.usp_Download_And_Load_S3_Files
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @run_id UNIQUEIDENTIFIER = NEWID();

    DECLARE @baseS3Prefix NVARCHAR(300) =
        'arn:aws:s3:::bi-staging.tenproduct.com/BE_DJANGO_POSTGRES_CSV/TP_20260209220038/';

    DECLARE @baseLocalPrefix NVARCHAR(300) =
        'D:\S3\BE_DJANGO_POSTGRES_CSV\TP_20260209220038\';

    /*File manifest*/
    DECLARE @files TABLE
    (
        file_name     NVARCHAR(200),
        target_schema SYSNAME,
        target_table  SYSNAME
    );

    INSERT INTO @files (file_name, target_schema, target_table)
    VALUES
        ('articles.csv', 'django', 'articles'),
        ('brands.csv', 'django', 'brands'),
        ('dining_celebrity_chefs.csv', 'django', 'dining_celebrity_chefs'),
        ('dining_cuisine.csv', 'django', 'dining_cuisine'),
        ('dining_hot_table_bookings.csv', 'django', 'dining_hot_table_bookings'),
        ('dining_hot_tables.csv', 'django', 'dining_hot_tables'),
        ('dining_restaurant_benefits.csv', 'django', 'dining_restaurant_benefits'),
        ('dining_restaurants.csv', 'django', 'dining_restaurants'),
        ('email_templates.csv', 'django', 'email_templates'),
        ('entertainment_artists.csv', 'django', 'entertainment_artists'),
        ('entertainment_bookings.csv', 'django', 'entertainment_bookings'),
        ('entertainment_delivery_methods.csv', 'django', 'entertainment_delivery_methods'),
        ('entertainment_event_tags.csv', 'django', 'entertainment_event_tags'),
        ('entertainment_events.csv', 'django', 'entertainment_events'),
        ('entertainment_performances.csv', 'django', 'entertainment_performances'),
        ('entertainment_ticket_types.csv', 'django', 'entertainment_ticket_types'),
        ('entertainment_venues.csv', 'django', 'entertainment_venues'),
        ('interest_id_entertainment_events.csv', 'django', 'interest_id_entertainment_events'),
        ('jobs.csv', 'django', 'jobs'),
        ('location_cities.csv', 'django', 'location_cities'),
        ('location_countries.csv', 'django', 'location_countries'),
        ('location_locationtags.csv', 'django', 'location_locationtags'),
        ('member_benefit_memberbenefit_sites.csv', 'django', 'member_benefit_memberbenefit_sites'),
        ('member_benefit_memberbenefit_tags.csv', 'django', 'member_benefit_memberbenefit_tags'),
        ('member_benefits.csv', 'django', 'member_benefits'),
        ('member_events.csv', 'django', 'member_events'),
        ('member_events_bookings.csv', 'django', 'member_events_bookings'),
        ('member_events_dates.csv', 'django', 'member_events_dates'),
        ('member_events_memberevent.csv', 'django', 'member_events_memberevent'),
        ('member_events_memberevent_tags.csv', 'django', 'member_events_memberevent_tags'),
        ('partners.csv', 'django', 'partners'),
        ('sites.csv', 'django', 'sites'),
        ('tags.csv', 'django', 'tags'),
        ('travel_airport_groups.csv', 'django', 'travel_airport_groups'),
        ('travel_airports.csv', 'django', 'travel_airports'),
        ('travel_car_hire_depots.csv', 'django', 'travel_car_hire_depots'),
        ('travel_hotels.csv', 'django', 'travel_hotels');

    /*----------------------------------------------------
      Ensure schema exists
    ----------------------------------------------------*/
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'django')
        EXEC ('CREATE SCHEMA django AUTHORIZATION dbo;');

    /*----------------------------------------------------
      3. SUBMIT DOWNLOADS
    ----------------------------------------------------*/
    DECLARE
        @file_name NVARCHAR(200),
        @target_schema SYSNAME,
        @target_table SYSNAME,
        @s3_path NVARCHAR(500),
        @local_path NVARCHAR(500);

    DECLARE file_cur CURSOR FAST_FORWARD FOR
        SELECT file_name, target_schema, target_table
        FROM @files;

    OPEN file_cur;
    FETCH NEXT FROM file_cur INTO @file_name, @target_schema, @target_table;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @s3_path = @baseS3Prefix + @file_name;
        SET @local_path = @baseLocalPrefix + @file_name;

        INSERT INTO django.S3_Download_Tracking
        (
            run_id, file_name, target_schema, target_table,
            s3_path, local_path
        )
        VALUES
        (
            @run_id, @file_name, @target_schema, @target_table,
            @s3_path, @local_path
        );

        BEGIN TRY
            DECLARE @submit_task_id INT, @task_lifecycle VARCHAR(50), @task_info NVARCHAR(MAX);

            EXEC msdb.dbo.rds_download_from_s3
                 @s3_arn_of_file = @s3_path,
                 @rds_file_path  = @local_path,
                 @overwrite_file = 1;

            SELECT TOP 1
                @submit_task_id = task_id,
                @task_lifecycle = lifecycle,
                @task_info = task_info
            FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
            WHERE task_type IN ('DOWNLOAD_FROM_S3','S3_DOWNLOAD')
            ORDER BY task_id DESC;

            UPDATE django.S3_Download_Tracking
            SET task_id = @submit_task_id,
                lifecycle = @task_lifecycle,
                task_info = @task_info
            WHERE run_id = @run_id
              AND file_name = @file_name;
        END TRY

        BEGIN CATCH
            UPDATE django.S3_Download_Tracking
            SET lifecycle = 'SUBMIT_FAILED',
                task_info = ERROR_MESSAGE()
            WHERE run_id = @run_id
              AND file_name = @file_name;
        END CATCH;

        FETCH NEXT FROM file_cur INTO @file_name, @target_schema, @target_table;
    END

    CLOSE file_cur;
    DEALLOCATE file_cur;

    /*----------------------------------------------------
      4. WAIT FOR DOWNLOADS TO FINISH
    ----------------------------------------------------*/
    DECLARE @task_id INT, @status VARCHAR(50), @poll_task_info NVARCHAR(MAX);

    DECLARE wait_cur CURSOR FAST_FORWARD FOR
        SELECT task_id, file_name
        FROM django.S3_Download_Tracking
        WHERE run_id = @run_id
          AND task_id IS NOT NULL;

    OPEN wait_cur;
    FETCH NEXT FROM wait_cur INTO @task_id, @file_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @status = 'CREATED';

        WHILE @status IN ('CREATED', 'IN_PROGRESS')
        BEGIN
            WAITFOR DELAY '00:00:05';

            SELECT TOP 1
                @status = lifecycle,
                @poll_task_info = task_info
            FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
            WHERE task_id = @task_id
            ORDER BY task_id DESC;
        END

        UPDATE django.S3_Download_Tracking
        SET lifecycle = @status,
            task_info = @poll_task_info,
            completed_at = GETDATE()
        WHERE run_id = @run_id
          AND task_id = @task_id;

        FETCH NEXT FROM wait_cur INTO @task_id, @file_name;
    END

    CLOSE wait_cur;
    DEALLOCATE wait_cur;

    /*----------------------------------------------------
      5. LOAD SUCCESSFUL DOWNLOADS
    ----------------------------------------------------*/
    DECLARE load_cur CURSOR FAST_FORWARD FOR
        SELECT file_name, target_schema, target_table, local_path
        FROM django.S3_Download_Tracking
        WHERE run_id = @run_id
          AND lifecycle = 'SUCCESS';

    OPEN load_cur;
    FETCH NEXT FROM load_cur INTO @file_name, @target_schema, @target_table, @local_path;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @process_id UNIQUEIDENTIFIER = NEWID();
        DECLARE @full_table NVARCHAR(300) = QUOTENAME(@target_schema) + '.' + QUOTENAME(@target_table);

        BEGIN TRY
            IF OBJECT_ID(@full_table, 'U') IS NULL
                THROW 50001, 'Target table does not exist.', 1;

            INSERT INTO django.S3_Load_Tracking
            (
                run_id, file_name, target_schema, target_table,
                local_path, process_id, status
            )
            VALUES
            (
                @run_id, @file_name, @target_schema, @target_table,
                @local_path, @process_id, 'STARTED'
            );

            DECLARE
                @InsertCols NVARCHAR(MAX),
                @SelectCols NVARCHAR(MAX),
                @RawCols NVARCHAR(MAX),
                @HasIdentity BIT = 0,
                @InsertedOnCol NVARCHAR(200),
                @ProcessIdCol NVARCHAR(200),
                @FileNameCol NVARCHAR(200),
                @sql NVARCHAR(MAX),
                @RowsInserted INT = 0,
                @FieldTerm NVARCHAR(5) = '|',
                @RowTerm NVARCHAR(10) = '0x0A';

            SELECT
                @InsertCols = STRING_AGG(QUOTENAME(c.name), ', ') WITHIN GROUP (ORDER BY c.column_id),
                @SelectCols = STRING_AGG(
                    'TRY_CONVERT(' +
                    CASE
                        WHEN tt.name IN ('varchar','char','varbinary','binary')
                            THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
                        WHEN tt.name IN ('nvarchar','nchar')
                            THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length/2 AS VARCHAR(10)) END + ')'
                        WHEN tt.name IN ('decimal','numeric')
                            THEN tt.name + '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
                        WHEN tt.name IN ('datetime2','datetimeoffset','time')
                            THEN tt.name + '(' + CAST(c.scale AS VARCHAR(10)) + ')'
                        ELSE tt.name
                    END +
                    ', NULLIF(' + QUOTENAME(c.name) + ', ''''))'
                , ', ') WITHIN GROUP (ORDER BY c.column_id),
                @RawCols = STRING_AGG(
                    '    ' + QUOTENAME(c.name) + ' NVARCHAR(4000)',
                    ',' + CHAR(13) + CHAR(10)
                ) WITHIN GROUP (ORDER BY c.column_id)
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            JOIN sys.types tt  ON tt.user_type_id = c.user_type_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND c.is_computed = 0
              AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

            IF @InsertCols IS NULL
                THROW 50002, 'No loadable columns found.', 1;

            SELECT @InsertedOnCol = QUOTENAME(c.name)
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND LOWER(c.name) = 'inserted_on';

            SELECT @ProcessIdCol = QUOTENAME(c.name)
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND LOWER(c.name) = 'processid';

            SELECT @FileNameCol = QUOTENAME(c.name)
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND LOWER(c.name) = 'filename';

            SELECT TOP 1 @HasIdentity = 1
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND c.is_identity = 1
              AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

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
                SET @SelectCols = @SelectCols + ', @fname';
            END

            SET @sql = N'
IF OBJECT_ID(''tempdb..#RawData'') IS NOT NULL
    DROP TABLE #RawData;

CREATE TABLE #RawData
(
' + @RawCols + '
);

BULK INSERT #RawData
FROM ''' + REPLACE(@local_path, '''', '''''') + '''
WITH
(
    FIELDTERMINATOR = ' + QUOTENAME(@FieldTerm, '''') + ',
    ROWTERMINATOR   = ' + QUOTENAME(@RowTerm, '''') + ',
    FIRSTROW        = 2,
    CODEPAGE        = ''65001'',
    TABLOCK
);

TRUNCATE TABLE ' + @full_table + ';
' +
CASE WHEN @HasIdentity = 1
     THEN 'SET IDENTITY_INSERT ' + @full_table + ' ON;'
     ELSE ''
END + '
INSERT INTO ' + @full_table + '(' + @InsertCols + ')
SELECT ' + @SelectCols + '
FROM #RawData;

SELECT @out_rows = @@ROWCOUNT;
' +
CASE WHEN @HasIdentity = 1
     THEN 'SET IDENTITY_INSERT ' + @full_table + ' OFF;'
     ELSE ''
END + '
DROP TABLE #RawData;
';

            EXEC sp_executesql
                @sql,
                N'@pid UNIQUEIDENTIFIER, @fname NVARCHAR(260), @out_rows INT OUTPUT',
                @pid = @process_id,
                @fname = @file_name,
                @out_rows = @RowsInserted OUTPUT;

            UPDATE django.S3_Load_Tracking
            SET status = 'SUCCESS',
                rows_inserted = @RowsInserted,
                finished_at = GETDATE()
            WHERE run_id = @run_id
              AND file_name = @file_name;

            BEGIN TRY
                EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = @local_path;
            END TRY
            BEGIN CATCH
                PRINT 'Cleanup warning for ' + @file_name + ': ' + ERROR_MESSAGE();
            END CATCH;
        END TRY
        BEGIN CATCH
            UPDATE django.S3_Load_Tracking
            SET status = 'FAILED',
                error_message = ERROR_MESSAGE(),
                finished_at = GETDATE()
            WHERE run_id = @run_id
              AND file_name = @file_name;

            IF @@ROWCOUNT = 0
            BEGIN
                INSERT INTO django.S3_Load_Tracking
                (
                    run_id, file_name, target_schema, target_table,
                    local_path, process_id, status, error_message, finished_at
                )
                VALUES
                (
                    @run_id, @file_name, @target_schema, @target_table,
                    @local_path, @process_id, 'FAILED', ERROR_MESSAGE(), GETDATE()
                );
            END
        END CATCH;

        FETCH NEXT FROM load_cur INTO @file_name, @target_schema, @target_table, @local_path;
    END

    CLOSE load_cur;
    DEALLOCATE load_cur;

    SELECT @run_id AS run_id;
END;
