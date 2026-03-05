/* ============================================================================
   SQL Agent Job: CMS_S3_Import

   Replaces: SSIS CMS package (download_files_from_s3_bucket.dtsx + 3 child loaders)

   What it does:
     1. Downloads CSV files from s3://bi-prod.tenproduct.com/CMS/ to D:\S3\CMS\
     2. Ensures the cms schema and tables exist
     3. Truncates cms.Dining, cms.Hotels, cms.Locations
     4. BULK INSERTs pipe-delimited CSVs into each table (with audit columns)
     5. Cleans up local files from D:\S3\CMS\

   S3 bucket:  bi-prod.tenproduct.com
   S3 prefix:  CMS/
   CSV format: Pipe-delimited (|), UTF-8, header row
   Dest DB:    TenDataWarehouse
   Dest schema: cms

   RDS procedures used:
     - msdb.dbo.rds_download_from_s3  (download CSV from S3)
     - msdb.dbo.rds_fn_task_status    (poll for download completion)
     - msdb.dbo.rds_delete_from_filesystem (clean up local files)
============================================================================ */
USE TEN_DATAWAREHOUSE;

IF DB_NAME() <> 'TEN_DATAWAREHOUSE' THROW 50000, 'Must run in TEN_DATAWAREHOUSE', 1;

-- ── IDEMPOTENT DROP ──
-- Attempt to delete job if it exists. sp_help_job will error if job doesn't exist,
-- which we catch and ignore. This approach doesn't require SELECT on sysjobs.
BEGIN TRY
    DECLARE @jobId BINARY(16);
    EXEC msdb.dbo.sp_help_job @job_name = N'CMS_S3_Import', @job_id = @jobId OUTPUT;
    IF @jobId IS NOT NULL
    BEGIN
        PRINT 'Deleting existing job: CMS_S3_Import';
        EXEC msdb.dbo.sp_delete_job @job_name = N'CMS_S3_Import', @delete_unused_schedule = 1;
    END
END TRY
BEGIN CATCH
    -- Job doesn't exist, which is fine - continue with creation
    PRINT 'Job does not exist yet, proceeding with creation.';
END CATCH
GO

-- ── CREATE JOB ──
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]' AND category_class = 1)
BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'[Uncategorized (Local)]'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode = msdb.dbo.sp_add_job
    @job_name        = N'CMS_S3_Import',
    @enabled         = 1,
    @notify_level_eventlog = 0,
    @notify_level_email    = 0,
    @notify_level_netsend  = 0,
    @notify_level_page     = 0,
    @delete_level          = 0,
    @description     = N'Downloads CMS CSV files (Dining, Hotels, Locations) from S3 and loads into TenDataWarehouse.cms schema. Replaces the SSIS CMS package.',
    @category_name   = N'[Uncategorized (Local)]',
    @owner_login_name = N'tenmaid_admin',
    @job_id          = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

/* ────────────────────────────────────────────────────────────────────────────
   STEP 1 — Download CSV files from S3 to D:\S3\CMS\
   Uses msdb.dbo.rds_download_from_s3 + polling via rds_fn_task_status.
   We download three known file patterns. Because rds_download_from_s3 works
   on individual files, we use a helper procedure that lists & downloads.

   NOTE: rds_download_from_s3 requires the exact S3 ARN per file.
   Since we may not know exact filenames up front, we create a stored proc
   that receives the S3 ARN and local path, downloads, and waits.
──────────────────────────────────────────────────────────────────────────── */
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
    @job_id          = @jobId,
    @step_name       = N'Download CMS files from S3 and load all tables',
    @step_id         = 1,
    @cmdexec_success_code = 0,
    @on_success_action = 1,    -- Quit with success
    @on_success_step_id = 0,
    @on_fail_action  = 2,      -- Quit with failure
    @on_fail_step_id = 0,
    @retry_attempts  = 0,
    @retry_interval  = 0,
    @os_run_priority = 0,
    @subsystem       = N'TSQL',
    @command          = N'
/* ============================================================================
   CMS_S3_Import — Main step

   This single T-SQL step handles the full pipeline:
     1. Ensure schema + tables exist in TEN_DATAWAREHOUSE
     2. Download each CSV from S3 → D:\S3\CMS\
     3. Truncate destination tables
     4. BULK INSERT from local file
     5. Clean up local files

   File patterns on S3:
     CMS/*Dining.csv        → cms.Dining
     CMS/*Hotels.csv        → cms.Hotels
     CMS/*Travel_Location.csv → cms.Locations

   NOTE: RDS procedures (rds_download_from_s3, rds_delete_from_filesystem,
         rds_fn_task_status) are called from msdb but operate on the local
         RDS instance.
============================================================================ */
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ProcessId VARCHAR(36) = CONVERT(CHAR(36), NEWID());
DECLARE @taskId INT;
DECLARE @status NVARCHAR(50);
DECLARE @s3Arn NVARCHAR(500);
DECLARE @localPath NVARCHAR(500);

-- ── 1. ENSURE SCHEMA ──
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N''cms'')
    EXEC(''CREATE SCHEMA cms AUTHORIZATION dbo'');

-- ── 2. ENSURE TABLES ──
IF OBJECT_ID(N''cms.Dining'', N''U'') IS NULL
    CREATE TABLE cms.Dining (
        dining_id          INT,
        ivector_id         INT,
        ten_maid_vendor_id INT,
        dining_name        NVARCHAR(255),
        location_id        INT,
        latitude           FLOAT,
        longitude          FLOAT,
        held_table         BIT,
        Inserted_On        DATETIME,
        ProcessId          VARCHAR(36),
        FileName           VARCHAR(255)
    );

IF OBJECT_ID(N''cms.Hotels'', N''U'') IS NULL
    CREATE TABLE cms.Hotels (
        accommodation_id    INT,
        ivector_id          INT,
        accommodation_name  NVARCHAR(255),
        rating              NUMERIC(3,1),
        latitude            FLOAT,
        longitude           FLOAT,
        location_id         INT,
        is_benefits_hotel   BIT,
        Inserted_On         DATETIME,
        ProcessId           VARCHAR(36),
        FileName            VARCHAR(255)
    );

IF OBJECT_ID(N''cms.Locations'', N''U'') IS NULL
    CREATE TABLE cms.Locations (
        location_id    INT,
        geo_level      NVARCHAR(50),
        langcode       NVARCHAR(5),
        location_name  NVARCHAR(500),
        latitude       FLOAT,
        longitude      FLOAT,
        Inserted_On    DATETIME,
        ProcessId      VARCHAR(36),
        FileName       VARCHAR(255)
    );

/* ────────────────────────────────────────────────────────────────────────
   Helper: Download one file from S3, poll until complete
──────────────────────────────────────────────────────────────────────── */
-- We store file config in a temp table and loop through each file
CREATE TABLE #CmsFiles (
    Id          INT IDENTITY(1,1),
    S3Arn       NVARCHAR(500),
    LocalPath   NVARCHAR(500),
    TableName   NVARCHAR(128),
    Processed   BIT DEFAULT 0
);

-- ═══════════════════════════════════════════════════════════════════════
-- INSERT THE S3 FILE ARNS YOU WANT TO DOWNLOAD HERE
-- Update these ARNs to match the actual CSV filenames in your S3 bucket.
-- If filenames change each run (e.g. dated), you will need a listing
-- mechanism or a fixed naming convention.
-- ═══════════════════════════════════════════════════════════════════════
INSERT INTO #CmsFiles (S3Arn, LocalPath, TableName) VALUES
    (N''arn:aws:s3:::bi-prod.tenproduct.com/CMS/Dining.csv'',          N''D:\S3\CMS\Dining.csv'',          N''cms.Dining''),
    (N''arn:aws:s3:::bi-prod.tenproduct.com/CMS/Hotels.csv'',          N''D:\S3\CMS\Hotels.csv'',          N''cms.Hotels''),
    (N''arn:aws:s3:::bi-prod.tenproduct.com/CMS/Travel_Location.csv'', N''D:\S3\CMS\Travel_Location.csv'', N''cms.Locations'');

-- ── 3. DOWNLOAD EACH FILE FROM S3 ──
DECLARE @fileId INT = 1;
DECLARE @maxFileId INT = (SELECT MAX(Id) FROM #CmsFiles);

WHILE @fileId <= @maxFileId
BEGIN
    SELECT @s3Arn = S3Arn, @localPath = LocalPath
    FROM #CmsFiles WHERE Id = @fileId;

    -- Start the download
    EXEC msdb.dbo.rds_download_from_s3
        @s3_arn_of_file  = @s3Arn,
        @rds_file_path   = @localPath,
        @overwrite_file  = 1;

    -- Get the task ID (most recent task for this file)
    SET @taskId = NULL;
    SELECT TOP 1 @taskId = task_id
    FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
    WHERE task_type = ''S3_DOWNLOAD''
    ORDER BY task_id DESC;

    -- Poll until the download completes
    SET @status = N''IN_PROGRESS'';
    WHILE @status IN (N''CREATED'', N''IN_PROGRESS'')
    BEGIN
        WAITFOR DELAY ''00:00:05'';   -- poll every 5 seconds

        SELECT @status = lifecycle
        FROM msdb.dbo.rds_fn_task_status(NULL, @taskId);
    END

    IF @status <> N''SUCCESS''
        RAISERROR(''S3 download failed for %s — status: %s'', 16, 1, @s3Arn, @status);

    SET @fileId = @fileId + 1;
END

-- ── 4. TRUNCATE & BULK INSERT ──

-- ── Dining ──
TRUNCATE TABLE cms.Dining;

-- Stage into temp table (all VARCHAR) then INSERT with type conversion + audit cols
CREATE TABLE #Dining_Raw (
    dining_id          VARCHAR(50),
    ivector_id         VARCHAR(50),
    ten_maid_vendor_id VARCHAR(50),
    dining_name        NVARCHAR(255),
    location_id        VARCHAR(50),
    latitude           VARCHAR(50),
    longitude          VARCHAR(50),
    held_table         VARCHAR(50)
);

BULK INSERT #Dining_Raw
FROM ''D:\S3\CMS\Dining.csv''
WITH (
    FIELDTERMINATOR = ''|'',
    ROWTERMINATOR   = ''\n'',
    FIRSTROW        = 2,
    CODEPAGE        = ''65001'',
    TABLOCK
);

INSERT INTO cms.Dining (dining_id, ivector_id, ten_maid_vendor_id, dining_name,
                        location_id, latitude, longitude, held_table,
                        Inserted_On, ProcessId, FileName)
SELECT
    TRY_CAST(dining_id AS INT),
    TRY_CAST(ivector_id AS INT),
    TRY_CAST(ten_maid_vendor_id AS INT),
    dining_name,
    TRY_CAST(location_id AS INT),
    TRY_CAST(latitude AS FLOAT),
    TRY_CAST(longitude AS FLOAT),
    CASE WHEN held_table IN (''1'', ''True'', ''true'', ''TRUE'') THEN 1 ELSE 0 END,
    GETDATE(),
    @ProcessId,
    N''Dining.csv''
FROM #Dining_Raw;

DROP TABLE #Dining_Raw;

-- ── Hotels ──
TRUNCATE TABLE cms.Hotels;

CREATE TABLE #Hotels_Raw (
    accommodation_id   VARCHAR(50),
    ivector_id         VARCHAR(50),
    accommodation_name NVARCHAR(255),
    rating             VARCHAR(50),
    latitude           VARCHAR(50),
    longitude          VARCHAR(50),
    location_id        VARCHAR(50),
    is_benefits_hotel  VARCHAR(50)
);

BULK INSERT #Hotels_Raw
FROM ''D:\S3\CMS\Hotels.csv''
WITH (
    FIELDTERMINATOR = ''|'',
    ROWTERMINATOR   = ''\n'',
    FIRSTROW        = 2,
    CODEPAGE        = ''65001'',
    TABLOCK
);

INSERT INTO cms.Hotels (accommodation_id, ivector_id, accommodation_name, rating,
                        latitude, longitude, location_id, is_benefits_hotel,
                        Inserted_On, ProcessId, FileName)
SELECT
    TRY_CAST(accommodation_id AS INT),
    TRY_CAST(ivector_id AS INT),
    accommodation_name,
    TRY_CAST(rating AS NUMERIC(3,1)),
    TRY_CAST(latitude AS FLOAT),
    TRY_CAST(longitude AS FLOAT),
    TRY_CAST(location_id AS INT),
    CASE WHEN is_benefits_hotel IN (''1'', ''True'', ''true'', ''TRUE'') THEN 1 ELSE 0 END,
    GETDATE(),
    @ProcessId,
    N''Hotels.csv''
FROM #Hotels_Raw;

DROP TABLE #Hotels_Raw;

-- ── Locations ──
TRUNCATE TABLE cms.Locations;

CREATE TABLE #Locations_Raw (
    location_id   VARCHAR(50),
    geo_level     NVARCHAR(50),
    langcode      NVARCHAR(5),
    location_name NVARCHAR(500),
    latitude      VARCHAR(50),
    longitude     VARCHAR(50)
);

BULK INSERT #Locations_Raw
FROM ''D:\S3\CMS\Travel_Location.csv''
WITH (
    FIELDTERMINATOR = ''|'',
    ROWTERMINATOR   = ''\n'',
    FIRSTROW        = 2,
    CODEPAGE        = ''65001'',
    TABLOCK,
    KEEPNULLS
);

INSERT INTO cms.Locations (location_id, geo_level, langcode, location_name,
                           latitude, longitude,
                           Inserted_On, ProcessId, FileName)
SELECT
    TRY_CAST(location_id AS INT),
    geo_level,
    langcode,
    location_name,
    TRY_CAST(latitude AS FLOAT),
    TRY_CAST(longitude AS FLOAT),
    GETDATE(),
    @ProcessId,
    N''Travel_Location.csv''
FROM #Locations_Raw;

DROP TABLE #Locations_Raw;

-- ── 5. CLEAN UP LOCAL FILES ──
EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = N''D:\S3\CMS\Dining.csv'';
EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = N''D:\S3\CMS\Hotels.csv'';
EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = N''D:\S3\CMS\Travel_Location.csv'';

PRINT ''CMS_S3_Import completed — ProcessId: '' + @ProcessId;
',
    @database_name   = N'TenDataWarehouse',
    @flags           = 0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- ── SCHEDULE: Daily at 5am (matching original SSIS job) ──
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
    @job_id              = @jobId,
    @name                = N'Daily at 5am',
    @enabled             = 1,
    @freq_type           = 4,          -- Daily
    @freq_interval       = 1,          -- Every 1 day
    @freq_subday_type    = 1,          -- At the specified time
    @freq_subday_interval = 0,
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 0,
    @active_start_date   = 20260228,
    @active_end_date     = 99991231,
    @active_start_time   = 50000,      -- 05:00:00
    @active_end_time     = 235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO