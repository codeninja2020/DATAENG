-- DIAGNOSTIC QUERIES FOR DOWNLOAD TRACKING
-- Use these to verify the fix is working

USE TEN_DATAWAREHOUSE;

-- 1. Summary of latest run
SELECT TOP 1
    @run_id = run_id
FROM django.S3_Download_Tracking
ORDER BY submitted_at DESC;

PRINT '=== LATEST RUN SUMMARY ===';
SELECT
    run_id,
    COUNT(*) as total_files,
    SUM(CASE WHEN lifecycle IS NULL THEN 1 ELSE 0 END) as null_lifecycle_count,
    SUM(CASE WHEN task_id IS NOT NULL THEN 1 ELSE 0 END) as with_task_id,
    SUM(CASE WHEN lifecycle = 'SUCCESS' THEN 1 ELSE 0 END) as successful,
    SUM(CASE WHEN lifecycle = 'SUBMIT_FAILED' THEN 1 ELSE 0 END) as submit_failed,
    SUM(CASE WHEN lifecycle = 'SUBMITTED_PENDING_TASK_ID' THEN 1 ELSE 0 END) as pending_task_id
FROM django.S3_Download_Tracking
GROUP BY run_id
ORDER BY run_id DESC;

PRINT '';
PRINT '=== DETAILED STATUS BY LIFECYCLE ===';
SELECT
    lifecycle,
    COUNT(*) as count,
    MIN(submitted_at) as earliest,
    MAX(submitted_at) as latest
FROM django.S3_Download_Tracking
GROUP BY lifecycle
ORDER BY count DESC;

PRINT '';
PRINT '=== RECORDS WITH NULL LIFECYCLE (ISSUE) ===';
SELECT
    run_id, file_name, target_schema, target_table,
    task_id, submitted_at, completed_at, task_info
FROM django.S3_Download_Tracking
WHERE lifecycle IS NULL
ORDER BY submitted_at DESC;

PRINT '';
PRINT '=== RECORDS WITH NULL TASK_ID ===';
SELECT
    run_id, file_name, target_schema, target_table,
    lifecycle, submitted_at, completed_at, task_info
FROM django.S3_Download_Tracking
WHERE task_id IS NULL
ORDER BY submitted_at DESC;

PRINT '';
PRINT '=== FAILED SUBMISSIONS ===';
SELECT
    run_id, file_name, target_schema, target_table,
    lifecycle, task_id, submitted_at, task_info
FROM django.S3_Download_Tracking
WHERE lifecycle = 'SUBMIT_FAILED'
ORDER BY submitted_at DESC;

PRINT '';
PRINT '=== PENDING TASK ID (NOT YET REGISTERED) ===';
SELECT
    run_id, file_name, target_schema, target_table,
    lifecycle, task_id, submitted_at, task_info
FROM django.S3_Download_Tracking
WHERE lifecycle = 'SUBMITTED_PENDING_TASK_ID'
ORDER BY submitted_at DESC;

PRINT '';
PRINT '=== SUCCESSFUL DOWNLOADS ===';
SELECT
    run_id, file_name, target_schema, target_table,
    lifecycle, task_id, submitted_at, completed_at
FROM django.S3_Download_Tracking
WHERE lifecycle = 'SUCCESS'
ORDER BY completed_at DESC;

PRINT '';
PRINT '=== AWS RDS TASK STATUS (LIVE) ===';
SELECT TOP 20
    task_id,
    task_type,
    lifecycle,
    task_info,
    created_at,
    started_at,
    completed_at
FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
WHERE task_type = 'DOWNLOAD_FROM_S3'
ORDER BY task_id DESC;

PRINT '';
PRINT '=== LOAD TRACKING STATUS ===';
SELECT
    status,
    COUNT(*) as count,
    MIN(started_at) as earliest,
    MAX(started_at) as latest,
    SUM(CASE WHEN status = 'SUCCESS' THEN rows_inserted ELSE 0 END) as total_rows_loaded
FROM django.S3_Load_Tracking
GROUP BY status
ORDER BY status;

