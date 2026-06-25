/* Flyway Repeatable Migration */
/* Source: db/schema/staging/TENMAID_UAT/HSBC/HSBC_ETL/R__HSBC_ETL_SQLAgentJob.sql */

IF DB_NAME() <> 'msdb' THROW 50000, 'Must run in msdb', 1;
GO

-- 2. IDEMPOTENT DROP
DECLARE @jobExists BIT = 0;
BEGIN TRY
-- If job exists, sp_help_job returns a result set, else throws error
EXEC msdb.dbo.sp_help_job @job_name = N'HSBC ETL Local Validate Load';
SET @jobExists = 1;
END TRY
BEGIN CATCH
SET @jobExists = 0;
END CATCH
IF @jobExists = 1
BEGIN
PRINT 'Deleting existing job: HSBC ETL Local Validate Load';
EXEC msdb.dbo.sp_delete_job @job_name = N'HSBC ETL Local Validate Load', @delete_unused_schedule = 1;
END
GO

-- 3. CREATE JOB (based on preference_example/R__preference_SQLAgentJob.sql)
BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

-- Ensure default job category exists.
IF NOT EXISTS (
    SELECT name
    FROM msdb.dbo.syscategories
    WHERE name = N'[Uncategorized (Local)]'
      AND category_class = 1
)

BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category
        @class = N'JOB',
        @type  = N'LOCAL',
        @name  = N'[Uncategorized (Local)]';

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
END;



-- Create SQL Agent Job
DECLARE @jobId BINARY(16);

EXEC @ReturnCode = msdb.dbo.sp_add_job
      @job_name              = N'HSBC ETL Local Validate Load',
      @enabled               = 1,
      @notify_level_eventlog = 2,
      @notify_level_email    = 2,
      @delete_level          = 0,
      @description = N'Loads the local HSBC members CSV into HSBC_ETL.rawdatafeed, then validates and loads HSBC_ETL.tempmembers.',
      @category_name         = N'[Uncategorized (Local)]',
      @owner_login_name      = N'tendwh_admin',
      @job_id                = @jobId OUTPUT;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


-- Job Step 1: Load the local CSV into the raw staging table.
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
    @job_id            = @jobId,
    @step_name         = N'Load HSBC Raw Datafeed',
    @step_id           = 1,
    @subsystem         = N'TSQL',
    @database_name     = N'TENMAID_UAT',
    @command           = N'SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ProcessId VARCHAR(36) = CONVERT(VARCHAR(36), NEWID());
DECLARE @sourceRows INT;
DECLARE @SourcePath NVARCHAR(500) = N''__HSBC_LOCAL_DATAFEED_PATH__'';

IF OBJECT_ID(N''HSBC_ETL.rawdatafeed'', N''U'') IS NULL
    THROW 50301, ''HSBC_ETL.rawdatafeed does not exist.'', 1;

IF OBJECT_ID(''tempdb..#HSBC_members_datafeed_temp'') IS NOT NULL
    DROP TABLE #HSBC_members_datafeed_temp;

CREATE TABLE #HSBC_members_datafeed_temp
(
    CIN NVARCHAR(100) NULL,
    segment NVARCHAR(100) NULL,
    scheme_name NVARCHAR(200) NULL,
    membership_status NVARCHAR(50) NULL,
    title_code NVARCHAR(50) NULL,
    first_name NVARCHAR(200) NULL,
    last_name NVARCHAR(200) NULL,
    gender_code NVARCHAR(50) NULL,
    language_code NVARCHAR(50) NULL,
    date_of_birth NVARCHAR(50) NULL,
    address_line_1 NVARCHAR(500) NULL,
    address_line_2 NVARCHAR(500) NULL,
    town_city NVARCHAR(200) NULL,
    state_region NVARCHAR(200) NULL,
    post_code NVARCHAR(50) NULL,
    country_code NVARCHAR(50) NULL,
    email_address NVARCHAR(320) NULL,
    main_phone NVARCHAR(100) NULL,
    business_phone NVARCHAR(100) NULL,
    home_phone NVARCHAR(100) NULL
);

BULK INSERT #HSBC_members_datafeed_temp
FROM ''__HSBC_LOCAL_DATAFEED_PATH__''
WITH
(
    FORMAT = ''CSV'',
    FIRSTROW = 2,
    FIELDQUOTE = ''"'',
    ROWTERMINATOR = ''0x0A'',
    CODEPAGE = ''65001'',
    TABLOCK
);

SELECT @sourceRows = COUNT(*)
FROM #HSBC_members_datafeed_temp;

IF @sourceRows = 0
    THROW 50302, ''HSBC raw datafeed load aborted because the source file produced 0 rows.'', 1;

BEGIN TRANSACTION;

TRUNCATE TABLE HSBC_ETL.rawdatafeed;

INSERT INTO HSBC_ETL.rawdatafeed
(
    CIN,
    segment,
    scheme_name,
    membership_status,
    title_code,
    first_name,
    last_name,
    gender_code,
    language_code,
    date_of_birth,
    address_line_1,
    address_line_2,
    town_city,
    state_region,
    post_code,
    country_code,
    email_address,
    main_phone,
    business_phone,
    home_phone,
    load_ts,
    source,
    dq_passed,
    processid
)
SELECT
    NULLIF(LTRIM(RTRIM(REPLACE(CIN, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(segment, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(scheme_name, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(membership_status, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(title_code, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(first_name, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(last_name, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(gender_code, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(language_code, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(date_of_birth, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(address_line_1, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(address_line_2, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(town_city, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(state_region, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(post_code, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(country_code, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(email_address, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(main_phone, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(business_phone, CHAR(13), N''''))), N''''),
    NULLIF(LTRIM(RTRIM(REPLACE(home_phone, CHAR(13), N''''))), N''''),
    SYSDATETIME(),
    @SourcePath,
    0,
    @ProcessId
FROM #HSBC_members_datafeed_temp;

IF @@ROWCOUNT = 0
    THROW 50303, ''HSBC raw datafeed load aborted because 0 rows were inserted.'', 1;

COMMIT TRANSACTION;

DROP TABLE #HSBC_members_datafeed_temp;

PRINT ''Load complete - HSBC_ETL.rawdatafeed loaded. Rows: '' + CAST(@sourceRows AS VARCHAR(20))
    + ''. ProcessId: '' + @ProcessId;',
    @on_success_action = 3,      -- Go to next step
    @on_fail_action    = 2,      -- Quit with failure
    @retry_attempts    = 1,
    @retry_interval    = 5;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


-- Job Step 2: Validate raw rows and load changed rows into HSBC_ETL.tempmembers.
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
    @job_id            = @jobId,
    @step_name         = N'Validate Load HSBC Members',
    @step_id           = 2,
    @subsystem         = N'TSQL',
    @database_name     = N'TENMAID_UAT',
    @command           = N'SET NOCOUNT ON;

DECLARE @PrivateBankSchemeID INT;
DECLARE @PremierSchemeID INT;

SELECT TOP (1)
    @PrivateBankSchemeID = CorporateSchemeID
FROM dbo.CorporateScheme
WHERE LTRIM(RTRIM(Name)) IN (N''PrivateBank'', N''Private Bank'', N''HSBC PrivateBank'', N''HSBC Private Bank'')
ORDER BY CorporateSchemeID;

SELECT TOP (1)
    @PremierSchemeID = CorporateSchemeID
FROM dbo.CorporateScheme
WHERE LTRIM(RTRIM(Name)) IN (N''Premier'', N''HSBC Premier'')
ORDER BY CorporateSchemeID;

IF @PrivateBankSchemeID IS NULL
    THROW 50304, ''Could not resolve the HSBC PrivateBank SchemeID from dbo.CorporateScheme.'', 1;

IF @PremierSchemeID IS NULL
    THROW 50305, ''Could not resolve the HSBC Premier SchemeID from dbo.CorporateScheme.'', 1;

EXEC HSBC_ETL.Validate_And_Load_Datafeed_To_TempMembers
    @PrivateBankSchemeID = @PrivateBankSchemeID,
    @PremierSchemeID = @PremierSchemeID;',
    @on_success_action = 1,      -- Quit with success
    @on_fail_action    = 2,      -- Quit with failure
    @retry_attempts    = 1,
    @retry_interval    = 5;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


-- Set Starting Step
EXEC @ReturnCode = msdb.dbo.sp_update_job
    @job_id         = @jobId,
    @start_step_id  = 1;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

-- Add Schedule (Daily at 18:00)
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
    @job_id              = @jobId,
    @name                = N'HSBC ETL Local Validate Load - Daily 18:00',
    @enabled             = 1,       -- schedule enabled
    @freq_type           = 4,       -- daily
    @freq_interval       = 1,       -- every day
    @active_start_time   = 180000,  -- 06:00 PM
    @active_end_time     = 235959;  -- 11:59:59 PM

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


-- Assign job to server
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver
    @job_id      = @jobId,
    @server_name = N'(local)';

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


-- Commit if successful
COMMIT TRANSACTION;
GOTO EndSave;


-- Rollback on any error
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;


EndSave:
PRINT 'SQL Agent Job [HSBC ETL Local Validate Load] created successfully.';
GO
