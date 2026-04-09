USE msdb;
GO

SET NOCOUNT ON;
GO

BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

-- Ensure default job category exists
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
      @job_name              = N'Django S3 Full Load',
      @enabled               = 1,
      @notify_level_eventlog = 2,
      @notify_level_email    = 2,
      @delete_level          = 0,
      @description = N'Downloads 37 Django/Postgres CSV files from S3 (bi-staging bucket) '
                   + N'and truncate-loads the corresponding django.* tables in TEN_DATAWAREHOUSE. '
                   + N'Executes django.usp_Download_And_Load_S3_Files. '
                   + N'Updates django.S3_Download_Tracking and django.S3_Load_Tracking.',
      @category_name         = N'[Uncategorized (Local)]',
      @owner_login_name      = N'sa',
      @job_id                = @jobId OUTPUT;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


-- Job Step 1: Execute Stored Procedure
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
    @job_id            = @jobId,
    @step_name         = N'Download and Load Django S3 Files',
    @step_id           = 1,
    @subsystem         = N'TSQL',
    @database_name     = N'TenDataWarehouse_DB',
    @command           = N'EXEC django.usp_Download_And_Load_S3_Files;',
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


-- Add Schedule (Daily at 00:00)
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
    @job_id              = @jobId,
    @name                = N'Django S3 Full Load – Daily 00:00',
    @enabled             = 1,
    @freq_type           = 4,
    @freq_interval       = 1,
    @active_start_time   = 000000,
    @active_end_time     = 235959;

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
PRINT 'SQL Agent Job [Django S3 Full Load] created successfully.';
GO