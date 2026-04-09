
-- ══════════════════════════════════════════════════════════════════════════
-- PART D — SQL Agent Job definition (in msdb)
-- ══════════════════════════════════════════════════════════════════════════
USE msdb;
GO

-- Idempotent drop
DECLARE @jobExists BIT = 0;
BEGIN TRY
    EXEC msdb.dbo.sp_help_job @job_name = N'TenGroupFileLoader_Replication';
    SET @jobExists = 1;
END TRY
BEGIN CATCH SET @jobExists = 0; END CATCH
IF @jobExists = 1
    EXEC msdb.dbo.sp_delete_job @job_name = N'TenGroupFileLoader_Replication', @delete_unused_schedule = 1;
GO

SET XACT_ABORT ON;
BEGIN TRANSACTION
DECLARE @ReturnCode INT = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]' AND category_class = 1)
BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class = N'JOB', @type = N'LOCAL', @name = N'[Uncategorized (Local)]'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode = msdb.dbo.sp_add_job
    @job_name        = N'TenGroupFileLoader_Replication',
    @enabled         = 1,
    @notify_level_eventlog = 0,
    @notify_level_email    = 0,
    @notify_level_netsend  = 0,
    @notify_level_page     = 0,
    @delete_level          = 0,
    @description     = N'Replicates EmailForwardingLogs from tenmaid-global-db-prod.TenGroupFileLoader to TenDataWarehouse. Supports Full and Incremental (Change Tracking) modes. Replaces the SSIS TenGroupFileLoader package.',
    @category_name   = N'[Uncategorized (Local)]',
    @owner_login_name = N'tenmaid_admin',
    @job_id          = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
    @job_id          = @jobId,
    @step_name       = N'Load EmailForwardingLogs',
    @step_id         = 1,
    @cmdexec_success_code = 0,
    @on_success_action = 1,
    @on_fail_action  = 2,
    @retry_attempts  = 0,
    @retry_interval  = 0,
    @os_run_priority = 0,
    @subsystem       = N'TSQL',
    @command          = N'EXEC dbo.usp_TenGroupFileLoader_LoadEmailForwardingLogs;',
    @database_name   = N'TenDataWarehouse',
    @flags           = 0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- Schedule: Every 1 hour starting 00:35 (matching original SSIS job)
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
    @job_id              = @jobId,
    @name                = N'Every 1 Hour',
    @enabled             = 1,
    @freq_type           = 4,          -- Daily
    @freq_interval       = 1,
    @freq_subday_type    = 8,          -- Every X hours
    @freq_subday_interval = 1,         -- Every 1 hour
    @freq_relative_interval = 0,
    @freq_recurrence_factor = 0,
    @active_start_date   = 20260228,
    @active_end_date     = 99991231,
    @active_start_time   = 3500,       -- 00:35:00
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