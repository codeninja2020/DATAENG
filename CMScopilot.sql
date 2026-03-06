/* ============================================================================
   CMS IMPORT PIPELINE — FULL INSTALLATION SCRIPT
   Database:  TEN_DATAWAREHOUSE
   Schema:    dbo
   Tables:    Dining, Hotels, Locations
   Job:       CMS_S3_Import
   Replaces:  SSIS CMS package
============================================================================ */

USE TEN_DATAWAREHOUSE;
GO

/* ============================================================================
   STEP 1 — CREATE OR REPLACE STORED PROCEDURE dbo.usp_ImportCMS_FromS3
============================================================================ */

CREATE OR ALTER PROCEDURE dbo.usp_ImportCMS_FromS3
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @ProcessId VARCHAR(36) = CONVERT(CHAR(36), NEWID()),
        @taskId INT,
        @status NVARCHAR(50),
        @s3Arn NVARCHAR(500),
        @localPath NVARCHAR(500);

    --------------------------------------------------------------------------------
    -- 1. ENSURE TABLES EXIST in dbo
    --------------------------------------------------------------------------------
    IF OBJECT_ID('dbo.Dining', 'U') IS NULL
        CREATE TABLE dbo.Dining (
            dining_id INT,
            ivector_id INT,
            ten_maid_vendor_id INT,
            dining_name NVARCHAR(255),
            location_id INT,
            latitude FLOAT,
            longitude FLOAT,
            held_table BIT,
            Inserted_On DATETIME,
            ProcessId VARCHAR(36),
            FileName VARCHAR(255)
        );

    IF OBJECT_ID('dbo.Hotels', 'U') IS NULL
        CREATE TABLE dbo.Hotels (
            accommodation_id INT,
            ivector_id INT,
            accommodation_name NVARCHAR(255),
            rating NUMERIC(3,1),
            latitude FLOAT,
            longitude FLOAT,
            location_id INT,
            is_benefits_hotel BIT,
            Inserted_On DATETIME,
            ProcessId VARCHAR(36),
            FileName VARCHAR(255)
        );

    IF OBJECT_ID('dbo.Locations', 'U') IS NULL
        CREATE TABLE dbo.Locations (
            location_id INT,
            geo_level NVARCHAR(50),
            langcode NVARCHAR(5),
            location_name NVARCHAR(500),
            latitude FLOAT,
            longitude FLOAT,
            Inserted_On DATETIME,
            ProcessId VARCHAR(36),
            FileName VARCHAR(255)
        );

    --------------------------------------------------------------------------------
    -- 2. DEFINE FILES TO DOWNLOAD
    --------------------------------------------------------------------------------
    CREATE TABLE #Files (
        Id INT IDENTITY(1,1),
        S3Arn NVARCHAR(500),
        LocalPath NVARCHAR(500),
        Target NVARCHAR(50)
    );

    INSERT INTO #Files (S3Arn, LocalPath, Target)
    VALUES
        ('arn:aws:s3:::bi-prod.tenproduct.com/CMS/Dining.csv',          'D:\S3\CMS\Dining.csv',          'Dining'),
        ('arn:aws:s3:::bi-prod.tenproduct.com/CMS/Hotels.csv',          'D:\S3\CMS\Hotels.csv',          'Hotels'),
        ('arn:aws:s3:::bi-prod.tenproduct.com/CMS/Travel_Location.csv', 'D:\S3\CMS\Travel_Location.csv', 'Locations');

    --------------------------------------------------------------------------------
    -- 3. DOWNLOAD EACH FILE FROM S3
    --------------------------------------------------------------------------------
    DECLARE @i INT = 1, @max INT = (SELECT MAX(Id) FROM #Files);

    WHILE @i <= @max
    BEGIN
        SELECT @s3Arn = S3Arn, @localPath = LocalPath
        FROM #Files WHERE Id = @i;

        EXEC TEN_DATAWAREHOUSE.dbo.rds_download_from_s3
            @s3_arn_of_file = @s3Arn,
            @rds_file_path  = @localPath,
            @overwrite_file = 1;

        SELECT TOP 1 @taskId = task_id
        FROM TEN_DATAWAREHOUSE.dbo.rds_fn_task_status(NULL, NULL)
        WHERE task_type = 'S3_DOWNLOAD'
        ORDER BY task_id DESC;

        SET @status = 'IN_PROGRESS';

        WHILE @status IN ('CREATED','IN_PROGRESS')
        BEGIN
            WAITFOR DELAY '00:00:05';
            SELECT @status = lifecycle
            FROM TEN_DATAWAREHOUSE.dbo.rds_fn_task_status(NULL, @taskId);
        END

        IF @status <> 'SUCCESS'
            THROW 51000, 'S3 download failed.', 1;

        SET @i += 1;
    END

    --------------------------------------------------------------------------------
    -- 4. LOAD DINING
    --------------------------------------------------------------------------------
    TRUNCATE TABLE dbo.Dining;

    CREATE TABLE #Dining (
        dining_id VARCHAR(50),
        ivector_id VARCHAR(50),
        ten_maid_vendor_id VARCHAR(50),
        dining_name NVARCHAR(255),
        location_id VARCHAR(50),
        latitude VARCHAR(50),
        longitude VARCHAR(50),
        held_table VARCHAR(50)
    );

    BULK INSERT #Dining
    FROM 'D:\S3\CMS\Dining.csv'
    WITH (
        FIELDTERMINATOR = '|',
        ROWTERMINATOR   = '0x0A',
        FIRSTROW        = 2,
        CODEPAGE        = '65001'
    );

    INSERT INTO dbo.Dining
    SELECT
        TRY_CAST(dining_id AS INT),
        TRY_CAST(ivector_id AS INT),
        TRY_CAST(ten_maid_vendor_id AS INT),
        dining_name,
        TRY_CAST(location_id AS INT),
        TRY_CAST(latitude AS FLOAT),
        TRY_CAST(longitude AS FLOAT),
        CASE WHEN held_table IN ('1','TRUE','true','True') THEN 1 ELSE 0 END,
        SYSDATETIME(),
        @ProcessId,
        'Dining.csv'
    FROM #Dining;

    --------------------------------------------------------------------------------
    -- 5. LOAD HOTELS
    --------------------------------------------------------------------------------
    TRUNCATE TABLE dbo.Hotels;

    CREATE TABLE #Hotels (
        accommodation_id VARCHAR(50),
        ivector_id VARCHAR(50),
        accommodation_name NVARCHAR(255),
        rating VARCHAR(50),
        latitude VARCHAR(50),
        longitude VARCHAR(50),
        location_id VARCHAR(50),
        is_benefits_hotel VARCHAR(50)
    );

    BULK INSERT #Hotels
    FROM 'D:\S3\CMS\Hotels.csv'
    WITH (
        FIELDTERMINATOR = '|',
        ROWTERMINATOR   = '0x0A',
        FIRSTROW        = 2,
        CODEPAGE        = '65001'
    );

    INSERT INTO dbo.Hotels
    SELECT
        TRY_CAST(accommodation_id AS INT),
        TRY_CAST(ivector_id AS INT),
        accommodation_name,
        TRY_CAST(rating AS NUMERIC(3,1)),
        TRY_CAST(latitude AS FLOAT),
        TRY_CAST(longitude AS FLOAT),
        TRY_CAST(location_id AS INT),
        CASE WHEN is_benefits_hotel IN ('1','TRUE','true','True') THEN 1 ELSE 0 END,
        SYSDATETIME(),
        @ProcessId,
        'Hotels.csv'
    FROM #Hotels;

    --------------------------------------------------------------------------------
    -- 6. LOAD LOCATIONS
    --------------------------------------------------------------------------------
    TRUNCATE TABLE dbo.Locations;

    CREATE TABLE #Locations (
        location_id VARCHAR(50),
        geo_level NVARCHAR(50),
        langcode NVARCHAR(5),
        location_name NVARCHAR(500),
        latitude VARCHAR(50),
        longitude VARCHAR(50)
    );

    BULK INSERT #Locations
    FROM 'D:\S3\CMS\Travel_Location.csv'
    WITH (
        FIELDTERMINATOR = '|',
        ROWTERMINATOR   = '0x0A',
        FIRSTROW        = 2,
        CODEPAGE        = '65001'
    );

    INSERT INTO dbo.Locations
    SELECT
        TRY_CAST(location_id AS INT),
        geo_level,
        langcode,
        location_name,
        TRY_CAST(latitude AS FLOAT),
        TRY_CAST(longitude AS FLOAT),
        SYSDATETIME(),
        @ProcessId,
        'Travel_Location.csv'
    FROM #Locations;

    --------------------------------------------------------------------------------
    -- 7. CLEANUP FILES
    --------------------------------------------------------------------------------
    EXEC dbo.rds_delete_from_filesystem @rds_file_path = 'D:\S3\CMS\Dining.csv';
    EXEC dbo.rds_delete_from_filesystem @rds_file_path = 'D:\S3\CMS\Hotels.csv';
    EXEC dbo.rds_delete_from_filesystem @rds_file_path = 'D:\S3\CMS\Travel_Location.csv';

END;
GO


/* ============================================================================
   STEP 2 — SQL AGENT JOB CREATION
============================================================================ */

USE msdb;
GO

-- Delete existing job
IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'CMS_S3_Import')
    EXEC sp_delete_job @job_name = 'CMS_S3_Import';
GO

DECLARE @jobId UNIQUEIDENTIFIER;

EXEC sp_add_job
    @job_name = 'CMS_S3_Import',
    @enabled = 1,
    @description = 'Loads Dining, Hotels, Locations from S3 into TEN_DATAWAREHOUSE.dbo',
    @owner_login_name = 'tenmaid_admin',
    @job_id = @jobId OUTPUT;

EXEC sp_add_jobstep
    @job_id = @jobId,
    @step_name = 'Run CMS Import',
    @subsystem = 'TSQL',
    @database_name = 'TEN_DATAWAREHOUSE',
    @command = 'EXEC dbo.usp_ImportCMS_FromS3;',
    @on_fail_action = 2;

EXEC sp_add_jobschedule
    @job_id = @jobId,
    @name = 'Daily 5AM',
    @freq_type = 4,          -- daily
    @freq_interval = 1,      -- every day
    @active_start_time = 50000;  -- 05:00:00

EXEC sp_add_jobserver
    @job_id = @jobId,
    @server_name = '(local)';
GO

