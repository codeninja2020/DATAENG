-- =============================================================================
-- FILE        : django_s3_load_agent_job.sql
-- DESCRIPTION : Creates the SQL Server Agent job, operator, and alerts for
--               django.usp_Download_And_Load_S3_Files.
--
--               ALERTS COVERED
--               ---------------------------------------------------------------
--               A) SQL Agent Alert – severity 16 errors (WITH LOG)
--                  Catches any unhandled severity 16+ errors raised during
--                  S3 download or load phases.
--
--               B) Job-level email on failure (@notify_level_email = 2)
--                  Catches anything not covered by the severity alert –
--                  e.g. BULK INSERT permission denied, network timeout,
--                  missing schema, cursor errors.
--
--               C) Job-level email on success (@notify_level_email includes 1)
--                  Confirmation email when all 37 files load cleanly.
--
--               PREREQUISITE
--               ---------------------------------------------------------------
--               1. Database Mail is configured. Update @MailProfile below.
--               2. django.usp_Download_And_Load_S3_Files already exists.
--               3. django.S3_Download_Tracking and django.S3_Load_Tracking
--                  tables already exist (created by Flyway or separately).
--
-- =============================================================================

USE msdb;
GO

SET NOCOUNT ON;
GO

-- =============================================================================
-- CONFIGURATION  –  UPDATE BEFORE RUNNING
-- =============================================================================
-- @MailProfile   : the Database Mail profile name on your instance
-- @OperatorEmail : email address that receives all alerts
-- @RunTime       : daily start time as HHMMSS integer  (20000 = 02:00:00)
-- =============================================================================

DECLARE @MailProfile   SYSNAME       = N'DBA Alerts';            -- ← update
DECLARE @OperatorEmail NVARCHAR(100) = N'dba-team@company.com';  -- ← update
DECLARE @RunTime       INT           = 20000;                     -- ← update (02:00 AM)

-- =============================================================================
-- STEP 1 – ENSURE DATABASE MAIL XPs ARE ENABLED
-- (safe no-op if already on)
-- =============================================================================
EXEC master.dbo.sp_configure 'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;

EXEC master.dbo.sp_configure 'Database Mail XPs', 1;
RECONFIGURE WITH OVERRIDE;
GO

-- Point SQL Agent at the mail profile
-- Replace 'DBA Alerts' below with your actual profile name if different.
EXEC msdb.dbo.sp_set_sqlagent_properties
    @email_save_in_sent_folder = 1;
GO

-- =============================================================================
-- STEP 2 – CREATE OPERATOR (idempotent)
-- =============================================================================
IF NOT EXISTS (
    SELECT 1 FROM msdb.dbo.sysoperators
    WHERE name = N'Django S3 Load Operator'
)
BEGIN
    EXEC msdb.dbo.sp_add_operator
        @name                      = N'Django S3 Load Operator',
        @enabled                   = 1,
        @email_address             = N'dba-team@company.com',    -- ← update
        @weekday_pager_start_time  = 90000,
        @weekday_pager_end_time    = 180000,
        @saturday_pager_start_time = 90000,
        @saturday_pager_end_time   = 180000,
        @pager_days                = 62;   -- Mon–Sat bitmask
END;
GO

-- =============================================================================
-- STEP 3 – SQL AGENT ALERT: severity 16 (idempotent teardown + recreate)
--
-- The procedure uses SET XACT_ABORT ON and TRY/CATCH with THROW, which can
-- surface severity 16 errors. Adding WITH LOG to any THROW/RAISERROR inside
-- the proc will trigger this alert. It is also a safety net for any engine-
-- level severity 16 errors that bypass TRY/CATCH (e.g. BULK INSERT failures
-- that abort the batch).
-- =============================================================================
IF EXISTS (
    SELECT 1 FROM msdb.dbo.sysalerts
    WHERE name = N'Django S3 Load – Severity 16 Error'
)
    EXEC msdb.dbo.sp_delete_alert
        @name = N'Django S3 Load – Severity 16 Error';
GO

EXEC msdb.dbo.sp_add_alert
    @name                     = N'Django S3 Load – Severity 16 Error',
    @enabled                  = 1,
    @severity                 = 16,
    @delay_between_responses  = 120,     -- seconds – suppresses repeat alerts within 2 min
    @notification_message     = N'A severity 16 error was raised during the Django S3 load. '
                              + N'Check django.S3_Download_Tracking and django.S3_Load_Tracking '
                              + N'for rows where lifecycle = ''FAILED'' or status = ''FAILED''. '
                              + N'Review SQL Server error log and Agent job history for full detail.';
GO

EXEC msdb.dbo.sp_add_notification
    @alert_name          = N'Django S3 Load – Severity 16 Error',
    @operator_name       = N'Django S3 Load Operator',
    @notification_method = 1;   -- 1 = email
GO

-- =============================================================================
-- STEP 4 – CREATE AGENT JOB (idempotent teardown + recreate)
-- =============================================================================
IF EXISTS (
    SELECT 1 FROM msdb.dbo.sysjobs
    WHERE name = N'Django S3 Full Load'
)
BEGIN
    EXEC msdb.dbo.sp_delete_job
        @job_name                = N'Django S3 Full Load',
        @delete_unused_schedule  = 1;
END;
GO

EXEC msdb.dbo.sp_add_job
    @job_name                    = N'Django S3 Full Load',
    @enabled                     = 1,
    @description                 = N'Downloads 37 Django/Postgres CSV files from S3 '
                                 + N'(bi-staging bucket) and truncate-loads the '
                                 + N'corresponding django.* tables in TEN_DATAWAREHOUSE. '
                                 + N'Procedure: django.usp_Download_And_Load_S3_Files. '
                                 + N'Tracking tables: django.S3_Download_Tracking, '
                                 + N'django.S3_Load_Tracking.',
    @notify_level_eventlog       = 3,   -- log on success AND failure
    @notify_level_email          = 3,   -- email on success AND failure  (= alert level 2)
    @notify_email_operator_name  = N'Django S3 Load Operator',
    @delete_level                = 0;   -- keep job history
GO

-- =============================================================================
-- STEP 5 – JOB STEP: run the procedure
-- =============================================================================
EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'Django S3 Full Load',
    @step_name         = N'Download and Load Django S3 Files',
    @step_id           = 1,
    @subsystem         = N'TSQL',
    @database_name     = N'TEN_DATAWAREHOUSE',
    @command           = N'
/*
  Execute the Django S3 full load procedure.
  The procedure returns the run_id on completion.
  A post-run sanity check is included below so that any files that
  completed S3 download but failed during the DB load are surfaced
  immediately in the job history output.
*/
EXEC django.usp_Download_And_Load_S3_Files;

-- Post-run check: surface any failed loads into job history
-- so the failure is visible without querying tracking tables manually.
IF EXISTS (
    SELECT 1
    FROM django.S3_Load_Tracking
    WHERE status = ''FAILED''
      AND finished_at >= DATEADD(MINUTE, -60, GETDATE())
)
BEGIN
    DECLARE @failedFiles NVARCHAR(MAX);

    SELECT @failedFiles = STRING_AGG(file_name + '' | '' + ISNULL(error_message, ''no detail''), CHAR(13) + CHAR(10))
    FROM django.S3_Load_Tracking
    WHERE status = ''FAILED''
      AND finished_at >= DATEADD(MINUTE, -60, GETDATE());

    RAISERROR(
        ''[Django S3 Full Load] One or more files failed to load:%s%s'',
        16, 1,
        CHAR(13),
        @failedFiles
    ) WITH LOG;
END;

-- Surface any downloads that did not reach SUCCESS status
IF EXISTS (
    SELECT 1
    FROM django.S3_Download_Tracking
    WHERE lifecycle NOT IN (''SUCCESS'', ''SUBMITTED_PENDING_TASK_ID'')
      AND completed_at >= DATEADD(MINUTE, -60, GETDATE())
)
BEGIN
    DECLARE @failedDownloads NVARCHAR(MAX);

    SELECT @failedDownloads = STRING_AGG(file_name + '' | lifecycle: '' + ISNULL(lifecycle, ''NULL''), CHAR(13) + CHAR(10))
    FROM django.S3_Download_Tracking
    WHERE lifecycle NOT IN (''SUCCESS'', ''SUBMITTED_PENDING_TASK_ID'')
      AND completed_at >= DATEADD(MINUTE, -60, GETDATE());

    RAISERROR(
        ''[Django S3 Full Load] One or more S3 downloads did not reach SUCCESS:%s%s'',
        16, 2,
        CHAR(13),
        @failedDownloads
    ) WITH LOG;
END;
',
    @on_success_action = 1,   -- quit with success
    @on_fail_action    = 2,   -- quit with failure → triggers job-level email
    @retry_attempts    = 1,
    @retry_interval    = 10;  -- minutes between retries
GO

-- =============================================================================
-- STEP 6 – SCHEDULE: daily at 02:00 AM
-- Adjust @active_start_time (HHMMSS integer) as required.
-- =============================================================================
EXEC msdb.dbo.sp_add_schedule
    @schedule_name      = N'Django S3 Full Load – Daily 02:00',
    @freq_type          = 4,       -- daily
    @freq_interval      = 1,
    @active_start_time  = 20000,   -- 02:00:00  ← update if needed
    @active_end_time    = 235959;
GO

EXEC msdb.dbo.sp_attach_schedule
    @job_name      = N'Django S3 Full Load',
    @schedule_name = N'Django S3 Full Load – Daily 02:00';
GO

-- =============================================================================
-- STEP 7 – TARGET SERVER
-- =============================================================================
EXEC msdb.dbo.sp_add_jobserver
    @job_name    = N'Django S3 Full Load',
    @server_name = N'(LOCAL)';
GO

PRINT 'SQL Agent job [Django S3 Full Load] with alerts created successfully.';
GO

-- =============================================================================
-- REFERENCE: WHAT TRIGGERS AN EMAIL
-- =============================================================================
/*
    TRIGGER                                     MECHANISM           DETAILS
    ---------------------------------------------------------------------------
    Any severity 16 error raised WITH LOG       Agent Alert         Fires mid-run
                                                                    if RAISERROR or
                                                                    THROW surfaces a
                                                                    severity 16 error
                                                                    to the event log

    One or more files in S3_Load_Tracking       Post-run RAISERROR  RAISERROR(...,16,1)
    with status = 'FAILED'                      in job step         WITH LOG triggers
                                                                    both the Agent Alert
                                                                    AND fails the job
                                                                    step (job email)

    One or more files in S3_Download_Tracking   Post-run RAISERROR  Same as above but
    with non-SUCCESS lifecycle                  in job step         state 2

    Any unhandled engine error (BULK INSERT     Job-level email     @notify_level_email
    permission denied, network timeout,         on failure          = 3 catches step
    missing table, cursor error, etc.)                              failure even if no
                                                                    RAISERROR was raised

    Job completes with no errors                Job-level email     @notify_level_email
                                                on success          = 3 sends confirmation
                                                                    email on clean run

    ---------------------------------------------------------------------------
    TRACKING TABLES TO QUERY AFTER AN ALERT
    ---------------------------------------------------------------------------
    -- All downloads for the latest run
    SELECT * FROM django.S3_Download_Tracking
    ORDER BY completed_at DESC;

    -- All load outcomes for the latest run
    SELECT * FROM django.S3_Load_Tracking
    ORDER BY finished_at DESC;

    -- Failed loads only
    SELECT file_name, error_message, finished_at
    FROM django.S3_Load_Tracking
    WHERE status = 'FAILED'
    ORDER BY finished_at DESC;

    ---------------------------------------------------------------------------
    DEPLOYMENT ORDER
    ---------------------------------------------------------------------------
    1. Flyway: create django schema, S3_Download_Tracking, S3_Load_Tracking
    2. Deploy django.usp_Download_And_Load_S3_Files (the stored procedure)
    3. Run this script (creates operator, alert, job)
    4. Update @MailProfile name in sp_set_sqlagent_properties if your profile
       name differs from 'DBA Alerts'
    5. Test: EXEC TEN_DATAWAREHOUSE.django.usp_Download_And_Load_S3_Files
       Verify rows appear in both tracking tables and email arrives.
*/
