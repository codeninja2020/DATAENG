-- as of 11/03/2026 stored in DB
-- downloads CMS CSV files from S3 and loads CMS tables
--

-- DROP PROCEDURE IF IT EXISTS  + CREATE PROCEDURE
IF OBJECT_ID('cms.usp_FullLoad_CMS', 'P') IS NOT NULL
    DROP PROCEDURE cms.usp_FullLoad_CMS;
GO

CREATE PROCEDURE cms.usp_FullLoad_CMS
    @Environment NVARCHAR(50) = 'staging'  -- e.g. change env 'staging', 'production'
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate @Environment against known values to prevent injection into the S3 ARN.
    IF @Environment NOT IN ('staging', 'production')
        THROW 50000, 'Invalid @Environment value. Allowed values: staging, production.', 1;

    -- DECLARE VARIABLES
    DECLARE @fileId    INT;
    DECLARE @maxFileId INT;
    DECLARE @s3Arn     NVARCHAR(500);
    DECLARE @localPath NVARCHAR(500);
    DECLARE @tableName NVARCHAR(128);
    DECLARE @taskId    INT;
    DECLARE @status    NVARCHAR(100);
    DECLARE @ProcessId VARCHAR(36) = CONVERT(VARCHAR(36), NEWID());

    DECLARE @baseS3Prefix NVARCHAR(300) =
        N'arn:aws:s3:::bi-' + @Environment + N'.tenproduct.com/';

    -- FILE MANIFEST

    IF OBJECT_ID('tempdb..#CmsFiles') IS NOT NULL
        DROP TABLE #CmsFiles;

    CREATE TABLE #CmsFiles (
        Id        INT          IDENTITY(1,1) PRIMARY KEY,
        S3Arn     NVARCHAR(500) NOT NULL,
        LocalPath NVARCHAR(500) NOT NULL,
        TableName NVARCHAR(128) NOT NULL
    );

    INSERT INTO #CmsFiles (S3Arn, LocalPath, TableName)
    VALUES
        (
            @baseS3Prefix + N'CMS/Dining.csv',
            N'D:\S3\CMS\Dining.csv',
            N'cms.Dining'
        ),
        (
            @baseS3Prefix + N'CMS/Hotels.csv',
            N'D:\S3\CMS\Hotels.csv',
            N'cms.Hotels'
        ),
        (
            @baseS3Prefix + N'CMS/Travel_Location.csv',
            N'D:\S3\CMS\Travel_Location.csv',
            N'cms.Locations'
        );

    --  DOWNLOAD EACH FILE FROM S3
    SET @fileId = 1;
    SELECT @maxFileId = MAX(Id) FROM #CmsFiles;

    WHILE @fileId <= @maxFileId
    BEGIN
        SELECT
            @s3Arn    = S3Arn,
            @localPath = LocalPath,
            @tableName = TableName
        FROM #CmsFiles
        WHERE Id = @fileId;

        -- Record the download intent in the tracking table before submitting.
        INSERT INTO cms.S3_Download_Tracking
            (run_id, file_name, s3_path, local_path, target_table, lifecycle, submitted_at)
        VALUES
            (
                @ProcessId,
                SUBSTRING(@s3Arn, LEN(@baseS3Prefix + N'CMS/') + 1, LEN(@s3Arn)),  -- bare filename
                @s3Arn,
                @localPath,
                @tableName,
                N'SUBMITTED',
                GETDATE()
            );

        EXEC msdb.dbo.rds_download_from_s3
            @s3_arn_of_file = @s3Arn,
            @rds_file_path  = @localPath,
            @overwrite_file = 1;

        -- Locate the task created for THIS file specifically:
        --   • filter by S3_object_arn  (= @s3Arn)
        --   • filter by filepath       (= @localPath)
        --   • order by last_updated DESC so we always get the most-recent task
        --     if the same file was submitted more than once.
        SET @taskId = NULL;

        SELECT TOP (1)
            @taskId = task_id
        FROM msdb.dbo.rds_fn_task_status(NULL, 0)
        WHERE task_type    = N'DOWNLOAD_FROM_S3'
          AND S3_object_arn = @s3Arn
          AND filepath      = @localPath
        ORDER BY last_updated DESC;

        -- Persist the resolved task_id back into the tracker.
        UPDATE cms.S3_Download_Tracking
        SET    task_id     = @taskId,
               lifecycle   = CASE WHEN @taskId IS NULL THEN N'TASK_ID_NOT_FOUND' ELSE lifecycle END,
               last_updated = GETDATE()
        WHERE  run_id    = @ProcessId
          AND  s3_path   = @s3Arn
          AND  local_path = @localPath;

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
            WAITFOR DELAY '00:00:30';

            SELECT TOP (1)
                @status = lifecycle
            FROM msdb.dbo.rds_fn_task_status(@taskId, 0);
        END;

        -- Update final lifecycle in the tracker.
        UPDATE cms.S3_Download_Tracking
        SET    lifecycle    = @status,
               completed_at = GETDATE(),
               last_updated = GETDATE()
        WHERE  run_id    = @ProcessId
          AND  s3_path   = @s3Arn
          AND  local_path = @localPath;

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

    PRINT 'Download completed all CMS files downloaded from S3.';

    -- LOAD cms.Dining
    TRUNCATE TABLE cms.Dining;

    IF OBJECT_ID('tempdb..#Dining_temp') IS NOT NULL
        DROP TABLE #Dining_temp;

    CREATE TABLE #Dining_temp (
        dining_id          VARCHAR(50)   NULL,
        ivector_id         VARCHAR(50)   NULL,
        ten_maid_vendor_id VARCHAR(50)   NULL,
        dining_name        NVARCHAR(255) NULL,
        location_id        VARCHAR(50)   NULL,
        latitude           VARCHAR(50)   NULL,
        longitude          VARCHAR(50)   NULL,
        held_table         VARCHAR(50)   NULL
    );

    BULK INSERT #Dining_temp
    FROM 'D:\S3\CMS\Dining.csv'
    WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR   = '0x0A',
    FIRSTROW        = 2,
    CODEPAGE        = '65001',
    TABLOCK
    );

    INSERT INTO cms.Dining(
        dining_id,
        ivector_id,
        ten_maid_vendor_id,
        dining_name,
        location_id,
        latitude,
        longitude,
        held_table,
        Inserted_On,
        ProcessId,
        FileName)

    SELECT
        TRY_CAST(dining_id          AS INT),
        TRY_CAST(ivector_id         AS INT),
        TRY_CAST(ten_maid_vendor_id AS INT),
        dining_name,
        TRY_CAST(location_id        AS INT),
        TRY_CAST(latitude           AS FLOAT),
        TRY_CAST(longitude          AS FLOAT),
        CASE
            WHEN held_table IN ('1', 'True', 'true', 'TRUE') THEN 1
            ELSE 0
        END,
        GETDATE(),
        @ProcessId,
        N'Dining.csv'
    FROM #Dining_temp;

    DROP TABLE #Dining_temp;
    PRINT 'Phase 2 complete – cms.Dining loaded.';

    -- LOAD cms.Hotels
    TRUNCATE TABLE cms.Hotels;

    IF OBJECT_ID('tempdb..#Hotels_temp') IS NOT NULL
        DROP TABLE #Hotels_temp;

    CREATE TABLE #Hotels_temp (
        accommodation_id   VARCHAR(50)   NULL,
        ivector_id         VARCHAR(50)   NULL,
        accommodation_name NVARCHAR(255) NULL,
        rating             VARCHAR(50)   NULL,
        latitude           VARCHAR(50)   NULL,
        longitude          VARCHAR(50)   NULL,
        location_id        VARCHAR(50)   NULL,
        is_benefits_hotel  VARCHAR(50)   NULL
    );

    BULK INSERT #Hotels_temp
    FROM 'D:\S3\CMS\Hotels.csv'
    WITH (
         FIELDTERMINATOR = '|',
         ROWTERMINATOR   = '0x0A',
         FIRSTROW        = 2,
         CODEPAGE        = '65001',
         TABLOCK
    );

    INSERT INTO cms.Hotels (
        accommodation_id,
        ivector_id,
        accommodation_name,
        rating,
        latitude,
        longitude,
        location_id,
        is_benefits_hotel,
        Inserted_On,
        ProcessId,
        FileName
    )
    SELECT
        TRY_CAST(accommodation_id AS INT),
        TRY_CAST(ivector_id       AS INT),
        accommodation_name,
        TRY_CAST(rating           AS DECIMAL(5,2)),
        TRY_CAST(latitude         AS FLOAT),
        TRY_CAST(longitude        AS FLOAT),
        TRY_CAST(location_id      AS INT),
        CASE
            WHEN is_benefits_hotel IN ('1', 'True', 'true', 'TRUE') THEN 1
            ELSE 0
        END,
        GETDATE(),
        @ProcessId,
        N'Hotels.csv'
    FROM #Hotels_temp;

    DROP TABLE #Hotels_temp;
    PRINT 'Phase 3 complete – cms.Hotels loaded.';

    -- PHASE 4 – LOAD cms.Locations
    TRUNCATE TABLE cms.Locations;

    IF OBJECT_ID('tempdb..#Locations_temp') IS NOT NULL
        DROP TABLE #Locations_temp;

    CREATE TABLE #Locations_temp (
        location_id   VARCHAR(50)   NULL,
        geo_level     NVARCHAR(50)  NULL,
        langcode      NVARCHAR(5)   NULL,
        location_name NVARCHAR(500) NULL,
        latitude      VARCHAR(50)   NULL,
        longitude     VARCHAR(50)   NULL
    );

    BULK INSERT #Locations_temp
    FROM 'D:\S3\CMS\Travel_Location.csv'
    WITH (
         FIELDTERMINATOR = '|',
         ROWTERMINATOR   = '0x0A',
         FIRSTROW        = 2,
         CODEPAGE        = '65001',
         TABLOCK
    );

    INSERT INTO cms.Locations (
        location_id,
        geo_level,
        langcode,
        location_name,
        latitude,
        longitude,
        Inserted_On,
        ProcessId,
        FileName
    )
    SELECT
        TRY_CAST(location_id AS INT),
        geo_level,
        langcode,
        location_name,
        TRY_CAST(latitude  AS FLOAT),
        TRY_CAST(longitude AS FLOAT),
        GETDATE(),
        @ProcessId,
        N'Travel_Location.csv'
    FROM #Locations_temp;

    DROP TABLE #Locations_temp;
    PRINT 'completed cms.Locations loaded.';

    -- ARCHIVE LOADED FILES IN S3 THEN DELETE LOCAL COPIES
    -- Each file is uploaded to CMS/archive/YYYYMMDD/ before the local copy is removed.
    DECLARE @archivePrefix NVARCHAR(500) =
        @baseS3Prefix
        + N'CMS/archive/'
       -- + CONVERT(NVARCHAR(8), GETDATE(), 112)           -- YYYYMMDD date segment removed
        + N'/';

    DECLARE @archiveArn   NVARCHAR(500);
    DECLARE @archiveTaskId INT;
    DECLARE @archiveStatus NVARCHAR(100);

    SET @fileId = 1;
    SELECT @maxFileId = MAX(Id) FROM #CmsFiles;

    WHILE @fileId <= @maxFileId
    BEGIN
        SELECT
            @localPath  = LocalPath,
            @s3Arn      = S3Arn
        FROM #CmsFiles
        WHERE Id = @fileId;

        -- Derive the archive ARN from the original file name (last segment of S3Arn).
        --
        SET @archiveArn = @archivePrefix
            + SUBSTRING(@s3Arn, LEN(@baseS3Prefix + N'CMS/') + 1, LEN(@s3Arn));

        BEGIN TRY
            EXEC msdb.dbo.rds_upload_to_s3
                @s3_arn_of_file = @archiveArn,
                @rds_file_path  = @localPath,
                @overwrite_file = 1;

            SET @archiveTaskId = NULL;

            SELECT TOP (1)
                @archiveTaskId = task_id
            FROM msdb.dbo.rds_fn_task_status(NULL, 0)
            WHERE task_type    = N'UPLOAD_TO_S3'
              AND S3_object_arn = @archiveArn     -- filter by S3_object_arn (destination)
              AND filepath      = @localPath      -- filter by filename (local source path)
            ORDER BY last_updated DESC;           -- most-recent task wins

            IF @archiveTaskId IS NOT NULL
            BEGIN
                SET @archiveStatus = N'CREATED';

                WHILE @archiveStatus IN (N'CREATED', N'IN_PROGRESS')
                BEGIN
                    WAITFOR DELAY '00:00:30';

                    SELECT TOP (1)
                        @archiveStatus = lifecycle
                    FROM msdb.dbo.rds_fn_task_status(@archiveTaskId, 0);
                END;

                IF @archiveStatus <> N'SUCCESS'
                    PRINT 'Warning: archive upload status for ' + @localPath + ' = ' + @archiveStatus;
                ELSE
                    PRINT 'Archived: ' + @localPath + ' -> ' + @archiveArn;
            END;
        END TRY
        BEGIN CATCH
            PRINT 'Warning: archive upload failed for ' + @localPath + ': ' + ERROR_MESSAGE();
        END CATCH;

        -- Delete local file regardless of archive outcome.
        BEGIN TRY
            EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = @localPath;
        END TRY
        BEGIN CATCH
            PRINT 'Warning: could not delete local file ' + @localPath + ': ' + ERROR_MESSAGE();
        END CATCH;

        SET @fileId = @fileId + 1;
    END;

    PRINT 'Archive and cleanup complete.';

    DROP TABLE #CmsFiles;

    PRINT 'CMS_S3_Import completed successfully. ProcessId: ' + @ProcessId;
END;
