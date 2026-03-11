-- =============================================================================
-- FILE        : django_s3_full_load_agent_job.sql
-- DESCRIPTION : Creates (or re-creates) the SQL Server Agent job that runs
--               django.usp_Download_And_Load_S3_Files on a daily schedule.
--               PREREQUISITE: django.usp_Download_And_Load_S3_Files must
--               already exist. Run the procedure script first.
-- =============================================================================

USE msdb;
GO

SET NOCOUNT ON;
GO

-- =============================================================================
-- IDEMPOTENT TEARDOWN
-- Safe to re-run: removes existing job + schedule before recreating.
-- =============================================================================
IF EXISTS (
    SELECT 1
    FROM msdb.dbo.sysjobs
    WHERE name = N'Django S3 Full Load'
)
BEGIN
    EXEC msdb.dbo.sp_delete_job
        @job_name                = N'Django S3 Full Load',
        @delete_unused_schedule  = 1;
END;
GO

-- =============================================================================
-- CREATE JOB
-- =============================================================================
EXEC msdb.dbo.sp_add_job
    @job_name              = N'Django S3 Full Load',
    @enabled               = 1,
    @description           = N'Downloads 37 Django/Postgres CSV files from S3 '
                           + N'(bi-staging bucket) and truncate-loads the corresponding '
                           + N'django.* tables in TEN_DATAWAREHOUSE. '
                           + N'Procedure: django.usp_Download_And_Load_S3_Files. '
                           + N'Tracking: django.S3_Download_Tracking, django.S3_Load_Tracking.',
    @notify_level_eventlog = 2,     -- write to Windows Event Log on failure
    @notify_level_email    = 0,     -- set to 2 and populate @notify_email_operator_name
                                    -- when an operator is configured
    @delete_level          = 0;     -- keep job history after run
GO

-- =============================================================================
-- JOB STEP – single step that calls the stored procedure
-- =============================================================================
EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'Django S3 Full Load',
    @step_name         = N'Download and Load Django S3 Files',
    @step_id           = 1,
    @subsystem         = N'TSQL',
    @database_name     = N'TEN_DATAWAREHOUSE',
    @command           = N'EXEC django.usp_Download_And_Load_S3_Files;',
    @on_success_action = 1,   -- quit reporting success
    @on_fail_action    = 2,   -- quit reporting failure
    @retry_attempts    = 1,
    @retry_interval    = 5;   -- minutes between retries
GO

-- =============================================================================
-- SCHEDULE – daily at 02:00 AM (adjust @active_start_time as required)
-- =============================================================================
EXEC msdb.dbo.sp_add_schedule
    @schedule_name     = N'Django S3 Full Load – Daily 02:00',
    @freq_type         = 4,       -- daily
    @freq_interval     = 1,       -- every 1 day
    @active_start_time = 20000,   -- 02:00:00
    @active_end_time   = 235959;
GO

EXEC msdb.dbo.sp_attach_schedule
    @job_name      = N'Django S3 Full Load',
    @schedule_name = N'Django S3 Full Load – Daily 02:00';
GO

-- =============================================================================
-- TARGET SERVER – local instance
-- =============================================================================
EXEC msdb.dbo.sp_add_jobserver
    @job_name    = N'Django S3 Full Load',
    @server_name = N'(LOCAL)';
GO

PRINT 'SQL Agent job [Django S3 Full Load] created successfully.';
GO

-- =============================================================================
-- NOTES
-- =============================================================================
/*
    1.  DEPLOYMENT ORDER
        Run the procedure script first (creates django.usp_Download_And_Load_S3_Files),
        then run this script. Both are idempotent and safe to re-run.

    2.  OPERATOR NOTIFICATION
        To enable email alerts on failure:
            - Configure Database Mail in SQL Server
            - Create an operator:  EXEC msdb.dbo.sp_add_operator ...
            - Re-run this script with @notify_level_email = 2 and
              @notify_email_operator_name = N'<operator name>'

    3.  SCHEDULE
        Currently set to 02:00 AM daily. Change @active_start_time (HHMMSS integer)
        to match your preferred run window.

    4.  RETRY
        One automatic retry after 5 minutes before the job is marked as failed.
        Adjust @retry_attempts and @retry_interval on the job step as needed.

    5.  TRACKING TABLES
        After each run, query the tracking tables to review outcomes:

        -- Download outcomes
        SELECT * FROM TEN_DATAWAREHOUSE.django.S3_Download_Tracking
        ORDER BY completed_at DESC;

        -- Load outcomes
        SELECT * FROM TEN_DATAWAREHOUSE.django.S3_Load_Tracking
        ORDER BY finished_at DESC;

        -- Failed loads only
        SELECT file_name, error_message, finished_at
        FROM TEN_DATAWAREHOUSE.django.S3_Load_Tracking
        WHERE status = 'FAILED'
        ORDER BY finished_at DESC;

    6.  MANUAL TEST
        After deploying, trigger a manual run from SSMS:
            SQL Server Agent > Jobs > Django S3 Full Load > Start Job at Step...
        Then verify row counts in the django.* target tables and check both
        tracking tables show lifecycle = 'SUCCESS' / status = 'SUCCESS'.
*/
