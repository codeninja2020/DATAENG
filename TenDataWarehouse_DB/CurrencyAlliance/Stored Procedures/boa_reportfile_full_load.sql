-- Downloads the BOA report file from S3 and loads CurrencyAlliance.BOA_ReportFile_S3.
-- The file name in the manifest is date-stamped; update it to match the file currently,
-- sitting in the S3 bucket before each run (or extend to accept it as a parameter

IF OBJECT_ID('CurrencyAlliance.usp_FullLoad_BOA_ReportFile', 'P') IS NOT NULL
    DROP PROCEDURE CurrencyAlliance.usp_FullLoad_BOA_ReportFile;
GO

CREATE PROCEDURE CurrencyAlliance.usp_FullLoad_BOA_ReportFile
    @FileName    NVARCHAR(200) = NULL,  -- override per report period
    @Environment NVARCHAR(50)  = 'staging' -- e.g. 'staging', 'production'
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate @Environment against known values to prevent injection into the S3 ARN
    IF @Environment NOT IN ('staging', 'production')
        THROW 50000, 'Invalid @Environment value. Allowed values: staging, production.', 1;

    DECLARE @fileId    INT;
    DECLARE @maxFileId INT;
    DECLARE @s3Arn     NVARCHAR(500);
    DECLARE @localPath NVARCHAR(500);
    DECLARE @tableName NVARCHAR(128);
    DECLARE @taskId    INT;
    DECLARE @status    NVARCHAR(100);
    DECLARE @ProcessId VARCHAR(36) = CONVERT(VARCHAR(36), NEWID());
    DECLARE @BasePath NVARCHAR(300) = N'D:\S3\CA_BOA_Reports\';

    IF @FileName IS NULL
    BEGIN
        IF OBJECT_ID('tempdb..#Files') IS NOT NULL
            DROP TABLE #Files;

        CREATE TABLE #Files (FileName NVARCHAR(400));

        INSERT INTO #Files
        EXEC xp_cmdshell 'dir /B /A-D "D:\S3\CA_BOA_Reports"';

        -- Remove junk rows
        DELETE FROM #Files WHERE FileName IS NULL;

        -- Pick latest matching file
        SELECT TOP 1 @FileName = FileName
        FROM #Files
        WHERE FileName LIKE 'ten_boa_redemptions_%'
          AND FileName LIKE '%.csv'
        ORDER BY FileName DESC;

        IF @FileName IS NULL
            THROW 50001, 'No matching BOA report files found.', 1;
    END

    -- FILE MANIFEST

    IF OBJECT_ID('tempdb..#BOAFiles') IS NOT NULL
        DROP TABLE #BOAFiles;

    CREATE TABLE #BOAFiles (
        Id        INT           IDENTITY(1,1) PRIMARY KEY,
        S3Arn     NVARCHAR(500) NOT NULL,
        LocalPath NVARCHAR(500) NOT NULL,
        TableName NVARCHAR(128) NOT NULL
    );

    INSERT INTO #BOAFiles (S3Arn, LocalPath, TableName)
    VALUES (
        N'arn:aws:s3:::bi-' + @Environment + N'.tenproduct.com/CA_BOA_Reports/' + @FileName,
        @BasePath  + @FileName,
        N'CurrencyAlliance.BOA_ReportFile_S3'
    );

    -- DOWNLOAD EACH FILE FROM S3

    SET @fileId = 1;
    SELECT @maxFileId = MAX(Id) FROM #BOAFiles;

    WHILE @fileId <= @maxFileId
    BEGIN
        SELECT
            @s3Arn     = S3Arn,
            @localPath = LocalPath,
            @tableName = TableName
        FROM #BOAFiles
        WHERE Id = @fileId;

        EXEC msdb.dbo.rds_download_from_s3
            @s3_arn_of_file = @s3Arn,
            @rds_file_path  = @localPath,
            @overwrite_file = 1;

        -- Locate the task created for this file.

        SET @taskId = NULL;

        SELECT TOP (1)
            @taskId = task_id
        FROM msdb.dbo.rds_fn_task_status(NULL, 0)
        WHERE task_type = 'DOWNLOAD_FROM_S3';

        IF @taskId IS NULL
        BEGIN
            RAISERROR(
                'Could not find task_id for file: %s. Aborting.',
                16, 1, @localPath
            );
            RETURN;
        END;

        -- Poll until the task leaves its transient states.

        SET @status = N'CREATED';

        WHILE @status IN (N'CREATED', N'IN_PROGRESS')
        BEGIN
            WAITFOR DELAY '00:02:00';

            SELECT TOP (1)
                @status = lifecycle
            FROM msdb.dbo.rds_fn_task_status(@taskId, 0);
        END;

        IF @status <> N'SUCCESS'
        BEGIN
            RAISERROR(
                'S3 download failed for %s. Final status: %s',
                16, 1, @s3Arn, @status
            );
            RETURN;
        END;

        SET @fileId = @fileId + 1;
    END;

    PRINT 'Download complete – BOA report file downloaded from S3.';

    -- LOAD CurrencyAlliance.BOA_ReportFile_S3

    TRUNCATE TABLE CurrencyAlliance.BOA_ReportFile_S3;

    IF OBJECT_ID('tempdb..#BOA_temp') IS NOT NULL
        DROP TABLE #BOA_temp;

    CREATE TABLE #BOA_temp (
        external_reference          NVARCHAR(50)   NULL,
        loyalty_system_id           NVARCHAR(50)   NULL,
        completed_at                NVARCHAR(50)   NULL,
        member_id                   NVARCHAR(256)  NULL,
        sub_category                NVARCHAR(50)   NULL,
        promotion_code              NVARCHAR(50)   NULL,
        loyalty_amount              NVARCHAR(50)   NULL,
        fiat_amount                 NVARCHAR(50)   NULL,
        channel                     NVARCHAR(50)   NULL,
        redemption_type             NVARCHAR(50)   NULL,
        total_amount                NVARCHAR(50)   NULL,
        rewards_vendor_id           NVARCHAR(50)   NULL,
        group_code                  NVARCHAR(100)  NULL,
        program_id                  NVARCHAR(100)  NULL,
        top_parent_transaction      NVARCHAR(100)  NULL,
        elite_redemption            NVARCHAR(50)   NULL,
        elite_redemptions_available NVARCHAR(50)   NULL,
        quantity                    NVARCHAR(50)   NULL
    );

    -- @localPath still holds the resolved path from the download loop above.
    -- BULK INSERT does not support parameterised paths; single-quote-escape and build dynamically.
    DECLARE @bulkSql NVARCHAR(MAX) =
        N'BULK INSERT #BOA_temp FROM ''' + REPLACE(@localPath, '''', '''''') + ''' '
        + N'WITH (FIELDTERMINATOR = ''|'', ROWTERMINATOR = ''0x0A'', '
        + N'FIRSTROW = 2, CODEPAGE = ''65001'', TABLOCK);';

    EXEC sp_executesql @bulkSql;

    INSERT INTO CurrencyAlliance.BOA_ReportFile_S3 (
        external_reference,
        loyalty_system_id,
        completed_at,
        member_id,
        sub_category,
        promotion_code,
        loyalty_amount,
        fiat_amount,
        channel,
        redemption_type,
        total_amount,
        rewards_vendor_id,
        group_code,
        program_id,
        top_parent_transaction,
        elite_redemption,
        elite_redemptions_available,
        quantity,
        InsertedOn,
        FileName
    )
    SELECT
        external_reference,
        loyalty_system_id,
        completed_at,
        member_id,
        sub_category,
        promotion_code,
        TRY_CAST(loyalty_amount              AS INT),
        TRY_CAST(fiat_amount                 AS FLOAT),
        channel,
        redemption_type,
        TRY_CAST(total_amount                AS FLOAT),
        rewards_vendor_id,
        group_code,
        program_id,
        top_parent_transaction,
        TRY_CAST(elite_redemption            AS INT),
        TRY_CAST(elite_redemptions_available AS INT),
        TRY_CAST(quantity                    AS INT),
        GETDATE(),
        @FileName
    FROM #BOA_temp;

    DROP TABLE #BOA_temp;
    PRINT 'Load complete – CurrencyAlliance.BOA_ReportFile_S3 loaded.';

    -- ARCHIVE TO S3 THEN DELETE LOCAL COPY
    DECLARE @archivePrefix   NVARCHAR(500) =
        N'arn:aws:s3:::bi-' + @Environment + N'.tenproduct.com/CA_BOA_Reports/archive/'
        + CONVERT(NVARCHAR(8), GETDATE(), 112) + N'/';
    DECLARE @archiveTaskId   INT;
    DECLARE @archiveStatus   NVARCHAR(100);

    BEGIN TRY
        EXEC msdb.dbo.rds_upload_to_s3
            @s3_arn_of_file = @archivePrefix + @FileName,
            @rds_file_path  = @localPath,
            @overwrite_file = 1;

        SELECT TOP (1) @archiveTaskId = task_id
        FROM msdb.dbo.rds_fn_task_status(NULL, 0)
        WHERE task_type = 'UPLOAD_TO_S3';

        IF @archiveTaskId IS NOT NULL
        BEGIN
            SET @archiveStatus = N'CREATED';
            WHILE @archiveStatus IN (N'CREATED', N'IN_PROGRESS')
            BEGIN
                WAITFOR DELAY '00:00:30';
                SELECT TOP (1) @archiveStatus = lifecycle
                FROM msdb.dbo.rds_fn_task_status(@archiveTaskId, 0);
            END;
            IF @archiveStatus <> N'SUCCESS'
                PRINT 'Warning: archive upload status for ' + @FileName + ' = ' + @archiveStatus;
            ELSE
                PRINT 'Archived: ' + @FileName;
        END;
    END TRY
    BEGIN CATCH
        PRINT 'Warning: archive upload failed for ' + @FileName + ': ' + ERROR_MESSAGE();
    END CATCH;

    BEGIN TRY
        EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = @localPath;
    END TRY
    BEGIN CATCH
        PRINT 'Cleanup warning for ' + @FileName + ': ' + ERROR_MESSAGE();
    END CATCH;

    DROP TABLE #BOAFiles;

    PRINT 'BOA_FullLoad completed successfully. ProcessId: ' + @ProcessId;
END;
GO
--