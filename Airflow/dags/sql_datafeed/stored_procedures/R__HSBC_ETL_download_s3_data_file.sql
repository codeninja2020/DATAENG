/* ============================================================================
   Repeatable migration: R__HSBC_ETL_download_s3_data_file.sql

   Purpose: Download members_datafeed_example.csv from S3 for the HSBC members ETL.

   S3 source:
     - arn:aws:s3:::bi-qa.tenproduct.com/HSBC/members_datafeed_example.csv

   Stored procedures updated:
     - HSBC_ETL.Download_S3_Members_File
============================================================================ */

USE TENMAID_UAT;
GO

-- Step 1: Ensure the HSBC_ETL schema exists before creating the procedure.
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'HSBC_ETL')
    EXEC (N'CREATE SCHEMA HSBC_ETL AUTHORIZATION dbo;');
GO

CREATE OR ALTER PROCEDURE HSBC_ETL.Download_S3_Members_File
    @DoDownload BIT = 1,
    @MaxWaitMinutes INT = 90
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Validate procedure inputs before any tracking rows are written.
    IF @MaxWaitMinutes < 1
        THROW 50101, 'Invalid @MaxWaitMinutes value. It must be greater than 0.', 1;

    IF OBJECT_ID(N'HSBC_ETL.S3_Download_Tracking', N'U') IS NULL
        THROW 50100, 'HSBC_ETL.S3_Download_Tracking does not exist.', 1;

    -- Step 2: Build the run metadata and the fixed S3/local file paths for this ETL.
    DECLARE @run_id UNIQUEIDENTIFIER = NEWID();
    DECLARE @FileName NVARCHAR(200) = N'members_datafeed_example.csv';
    DECLARE @TargetSchema SYSNAME = N'HSBC_ETL';
    DECLARE @TargetTable SYSNAME = N'rawdatafeed';
    DECLARE @s3Arn NVARCHAR(500) = N'arn:aws:s3:::bi-qa.tenproduct.com/HSBC/' + @FileName;
    DECLARE @localPath NVARCHAR(500) = N'D:\S3\HSBC\' + @FileName;
    DECLARE @maxWaits INT = ((@MaxWaitMinutes * 60) + 29) / 30;

    DECLARE
        @taskId INT,
        @status NVARCHAR(100),
        @previousTaskId INT,
        @waitCount INT,
        @requestedAt DATETIME2(0),
        @taskInfo NVARCHAR(MAX),
        @taskInfoSafe NVARCHAR(4000);

    -- Step 3: Support dry-run style execution by recording a successful run without calling S3.
    IF @DoDownload = 0
    BEGIN
        INSERT INTO HSBC_ETL.S3_Download_Tracking
            (run_id, file_name, target_schema, target_table, s3_path, local_path, lifecycle, completed_at)
        VALUES
            (@run_id, @FileName, @TargetSchema, @TargetTable, @s3Arn, @localPath, N'SUCCESS', SYSDATETIME());

        SELECT @run_id AS run_id;
        RETURN;
    END;

    -- Step 4: Record that the S3 download run has started.
    INSERT INTO HSBC_ETL.S3_Download_Tracking
        (run_id, file_name, target_schema, target_table, s3_path, local_path, lifecycle)
    VALUES
        (@run_id, @FileName, @TargetSchema, @TargetTable, @s3Arn, @localPath, N'STARTED');

    BEGIN TRY
        -- Step 5: Capture the latest existing RDS download task before starting a new one.
        SELECT @previousTaskId = ISNULL(MAX(task_id), 0)
        FROM msdb.dbo.rds_fn_task_status(NULL, 0)
        WHERE task_type = 'DOWNLOAD_FROM_S3';

        SET @requestedAt = SYSDATETIME();

        -- Step 6: Request the RDS S3 download into the local SQL Server file path.
        EXEC msdb.dbo.rds_download_from_s3
            @s3_arn_of_file = @s3Arn,
            @rds_file_path  = @localPath,
            @overwrite_file = 1;

        SET @taskId = NULL;
        SET @waitCount = 0;

        -- Step 7: Poll briefly until the RDS task id for this download is visible.
        WHILE @taskId IS NULL AND @waitCount < 12
        BEGIN
            WAITFOR DELAY '00:00:05';
            SET @waitCount = @waitCount + 1;

            SELECT TOP (1)
                @taskId = task_id
            FROM msdb.dbo.rds_fn_task_status(NULL, 0)
            WHERE task_type = 'DOWNLOAD_FROM_S3'
              AND task_id > @previousTaskId
              AND filepath = @localPath
              AND S3_object_arn = @s3Arn
              AND created_at >= @requestedAt
            ORDER BY task_id ASC;

            IF @taskId IS NULL
            BEGIN
                SELECT TOP (1)
                    @taskId = task_id
                FROM msdb.dbo.rds_fn_task_status(NULL, 0)
                WHERE task_type = 'DOWNLOAD_FROM_S3'
                  AND task_id > @previousTaskId
                ORDER BY task_id DESC;
            END;
        END;

        -- Step 8: Store the resolved task id for later audit and troubleshooting.
        UPDATE HSBC_ETL.S3_Download_Tracking
        SET task_id = @taskId
        WHERE run_id = @run_id
          AND file_name = @FileName;

        -- Step 9: Fail early if the RDS task cannot be identified.
        IF @taskId IS NULL
        BEGIN
            UPDATE HSBC_ETL.S3_Download_Tracking
            SET lifecycle = N'FAILED',
                completed_at = SYSDATETIME(),
                task_info = N'Could not find task_id for file: ' + @localPath
            WHERE run_id = @run_id
              AND file_name = @FileName;

            THROW 50102, 'Could not find task_id for S3 download. Aborting.', 1;
        END;

        SET @status = N'CREATED';
        SET @waitCount = 0;
        SET @taskInfo = NULL;

        -- Step 10: Poll the RDS task until it succeeds, fails, or exceeds the wait limit.
        WHILE @status IN (N'CREATED', N'IN_PROGRESS')
        BEGIN
            SELECT TOP (1)
                @status = lifecycle,
                @taskInfo = task_info
            FROM msdb.dbo.rds_fn_task_status(NULL, 0)
            WHERE task_id = @taskId;

            IF @status IN (N'CREATED', N'IN_PROGRESS')
            BEGIN
                SET @waitCount = @waitCount + 1;

                IF @waitCount > @maxWaits
                BEGIN
                    SET @status = N'TIMEOUT';
                    SET @taskInfo = N'Download polling exceeded the configured wait limit of '
                        + CONVERT(NVARCHAR(20), @MaxWaitMinutes) + N' minute(s).';
                    BREAK;
                END;

                WAITFOR DELAY '00:00:30';
            END;
        END;

        -- Step 11: Mark failed or timed-out downloads in tracking before surfacing the error.
        IF @status <> N'SUCCESS'
        BEGIN
            SET @taskInfoSafe = ISNULL(CONVERT(NVARCHAR(4000), @taskInfo), N'');

            UPDATE HSBC_ETL.S3_Download_Tracking
            SET lifecycle = @status,
                completed_at = SYSDATETIME(),
                task_info = N'S3 download failed. Final status: ' + @status
                    + CASE
                        WHEN @taskInfoSafe = N'' THEN N''
                        ELSE N'. Info: ' + @taskInfoSafe
                      END
            WHERE run_id = @run_id
              AND file_name = @FileName;

            RAISERROR('S3 download failed for %s. Final status: %s. Info: %s', 16, 1, @s3Arn, @status, @taskInfoSafe);
        END;

        -- Step 12: Mark the download as successful once the RDS task completes.
        UPDATE HSBC_ETL.S3_Download_Tracking
        SET lifecycle = N'SUCCESS',
            completed_at = SYSDATETIME(),
            task_info = @taskInfo
        WHERE run_id = @run_id
          AND file_name = @FileName;

        PRINT 'Download complete - ' + @FileName + ' downloaded from S3.';
    END TRY
    BEGIN CATCH
        -- Step 13: Record unexpected failures that were not already finalized above.
        IF NOT EXISTS
        (
            SELECT 1
            FROM HSBC_ETL.S3_Download_Tracking
            WHERE run_id = @run_id
              AND file_name = @FileName
              AND completed_at IS NOT NULL
        )
        BEGIN
            UPDATE HSBC_ETL.S3_Download_Tracking
            SET lifecycle = N'FAILED',
                completed_at = SYSDATETIME(),
                task_info = ERROR_MESSAGE()
            WHERE run_id = @run_id
              AND file_name = @FileName;
        END;

        THROW;
    END CATCH;

    -- Step 14: Return the run id so downstream load steps can correlate this download.
    SELECT @run_id AS run_id;
END;
GO
