-- FILE        : cms_full_load_agent_job.sql
-- Creates (or re-creates) the SQL Server Agent job that runs
-- cms.usp_FullLoad_CMS on a daily schedule.
-- PREREQUISITE: cms.usp_FullLoad_CMS procedure must already exist
-- (CMS_FULL_LOAD).

USE msdb;
GO

SET NOCOUNT ON;
GO

-- delete existing job if it exists
IF EXISTS (
    SELECT 1
    FROM msdb.dbo.sysjobs
    WHERE name = N'CMS Full Load'
)
BEGIN
    EXEC msdb.dbo.sp_delete_job
        @job_name                = N'CMS Full Load',
        @delete_unused_schedule  = 1;
END;
GO

-- create new job
EXEC msdb.dbo.sp_add_job
    @job_name              = N'CMS Full Load',
    @enabled               = 1,
    @description           = N'Downloads CMS CSV files from S3 (bi-staging bucket) '
                           + N'and truncate-loads cms.Dining, cms.Hotels, and '
                           + N'cms.Locations in TEN_DATAWAREHOUSE. '
                           + N'Calls: cms.usp_FullLoad_CMS.',
    @notify_level_eventlog = 2,
    @notify_level_email    = 0,
    @delete_level          = 0;
GO

-- JOB STEP – execute the stored procedure
EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'CMS Full Load',
    @step_name         = N'Download and Load CMS Files',
    @step_id           = 1,
    @subsystem         = N'TSQL',
    @database_name     = N'TEN_DATAWAREHOUSE',
    @command           = N'EXEC cms.usp_FullLoad_CMS;',
    @on_success_action = 1,
    @on_fail_action    = 2,
    @retry_attempts    = 1,
    @retry_interval    = 5;
GO

-- Schedule
EXEC msdb.dbo.sp_add_schedule
    @schedule_name     = N'CMS Full Load – Daily 02:00',
    @freq_type         = 4,
    @freq_interval     = 1,
    @active_start_time = 20000,
    @active_end_time   = 235959;
GO

EXEC msdb.dbo.sp_attach_schedule
    @job_name      = N'CMS Full Load',
    @schedule_name = N'CMS Full Load – Daily 02:00';
GO

-- Target
EXEC msdb.dbo.sp_add_jobserver
    @job_name    = N'CMS Full Load',
    @server_name = N'(LOCAL)';
GO

PRINT 'SQL Agent job [CMS Full Load] created successfully.';
GO
