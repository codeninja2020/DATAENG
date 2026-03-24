-- Django sql agent jjob
-- Creates (or re-creates) the SQL Server Agent job that runs
-- django.usp_Download_And_Load_S3_Files on a daily schedule.
-- PREREQUISITE: django.usp_Download_And_Load_S3_Files must
-- already exist. Run the procedure script first.

USE msdb;
GO

SET NOCOUNT ON;
GO

-- check for existing job delete if exists.
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

-- CREATE JOB
EXEC msdb.dbo.sp_add_job
    @job_name              = N'Django S3 Full Load',
    @enabled               = 1,
    @description           = N'Downloads 37 Django/Postgres CSV files from S3 '
                           + N'(bi-staging bucket) and truncate-loads the corresponding '
                           + N'django.* tables in TEN_DATAWAREHOUSE. '
                           + N'Procedure: django.usp_Download_And_Load_S3_Files. '
                           + N'Tracking: django.S3_Download_Tracking, django.S3_Load_Tracking.',
    @notify_level_eventlog = 2,
    @notify_level_email    = 2,
    @delete_level          = 0;
GO

-- run SP
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

-- schedule
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

-- target EXEC msdb.dbo.sp_add_jobserver
    @job_name    = N'Django S3 Full Load',
    @server_name = N'(LOCAL)';
GO

PRINT 'SQL Agent job [Django S3 Full Load] created successfully.';
GO

