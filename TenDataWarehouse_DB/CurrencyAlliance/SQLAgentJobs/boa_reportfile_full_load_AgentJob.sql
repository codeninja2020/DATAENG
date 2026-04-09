USE msdb;
GO

SET NOCOUNT ON;
GO

BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

-- Ensure default category exists

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
      @job_name              = N'CurrencyAlliance BOA Report Full Load',
      @enabled               = 1,
      @notify_level_eventlog = 2,
      @notify_level_email    = 2,
      @delete_level          = 0,
      @description = N'Downloads the BOA redemptions CSV file from S3 (bi-staging, CA_BOA_Reports bucket) '
                   + N'and truncate-loads CurrencyAlliance.BOA_ReportFile_S3 in TEN_DATAWAREHOUSE. '
                   + N'Calls CurrencyAlliance.usp_FullLoad_BOA_ReportFile. '
                   + N'Update @FileName parameter in the job step command to match the current report file.',
      @category_name         = N'[Uncategorized (Local)]',
      @owner_login_name      = N'sa',
      @job_id                = @jobId OUTPUT;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


-- Job Step 1: Execute Stored Procedure
-- Update @FileName to match the file currently sitting in the S3 bucket.

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
    @job_id            = @jobId,
    @step_name         = N'Download and Load BOA Report File',
    @step_id           = 1,
    @subsystem         = N'TSQL',
    @database_name     = N'TenDataWarehouse_DB',
    @command           = N'EXEC CurrencyAlliance.usp_FullLoad_BOA_ReportFile
    @FileName = N''ten_boa_redemptions_20211014_130545.csv'';',
    @on_success_action = 1,     -- Quit with success
    @on_fail_action    = 2,     -- Quit with failure
    @retry_attempts    = 1,
    @retry_interval    = 5;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
-- Set starting step

EXEC @ReturnCode = msdb.dbo.sp_update_job
    @job_id        = @jobId,
    @start_step_id = 1;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;


-- Add schedule (Daily at 02:00)

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
    @job_id              = @jobId,
    @name                = N'CurrencyAlliance BOA Report Full Load – Daily 02:00',
    @enabled             = 1,
    @freq_type           = 4,       -- daily
    @freq_interval       = 1,       -- every day
    @active_start_time   = 20000,   -- 02:00 AM
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


-- Rollback on error

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

EndSave:
PRINT 'SQL Agent Job [CurrencyAlliance BOA Report Full Load] created successfully.';
GO
