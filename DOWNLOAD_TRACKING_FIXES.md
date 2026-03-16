# Download Tracking Issue - Root Cause & Fixes

## Problem: No Downloads Recorded

The `django.usp_Download_And_Load_S3_Files` procedure was not properly recording download submissions in the `S3_Download_Tracking` table.

## Root Causes Identified

### 1. **Race Condition with Task ID Registration**
- **Issue**: The procedure calls `rds_download_from_s3` and immediately queries `rds_fn_task_status()` without waiting
- **Impact**: The task may not yet be registered in the system, so `@submit_task_id` would be NULL
- **Result**: No task_id recorded in tracking table

### 2. **Duplicate WHERE Clause in Task Type Filter**
- **Issue**: Line 723 had `WHERE task_type IN ('DOWNLOAD_FROM_S3','DOWNLOAD_FROM_S3')` - redundant
- **Impact**: While not breaking, it was inefficient

### 3. **Missing NULL Handling**
- **Issue**: When `@submit_task_id` was NULL, the UPDATE statement still tried to set it to NULL
- **Impact**: Records weren't being updated with any lifecycle status, making downloads "invisible"

### 4. **Insufficient Error Information**
- **Issue**: Error messages in CATCH block only contained `ERROR_MESSAGE()` without context
- **Impact**: Difficult to troubleshoot failures

## Fixes Applied

### 1. **Added 2-Second Delay Before Task Query**
```sql
-- Wait a moment for task to be registered
WAITFOR DELAY '00:00:02';
```
This gives AWS RDS time to register the task in the system before querying.

### 2. **Implemented Conditional UPDATE Logic**
```sql
IF @submit_task_id IS NOT NULL
BEGIN
    -- Update with actual task ID
    UPDATE django.S3_Download_Tracking
    SET task_id = @submit_task_id,
        lifecycle = ISNULL(@task_lifecycle, 'CREATED'),
        task_info = @task_info
    WHERE run_id = @run_id AND file_name = @file_name;
END
ELSE
BEGIN
    -- Mark as pending if task ID not yet available
    UPDATE django.S3_Download_Tracking
    SET lifecycle = 'SUBMITTED_PENDING_TASK_ID',
        task_info = 'Task submitted but ID not yet available in system'
    WHERE run_id = @run_id AND file_name = @file_name;
END
```

This ensures:
- Records are ALWAYS updated with a status
- Pending tasks can be monitored and retried later
- No "orphaned" records with no lifecycle status

### 3. **Fixed Task Type Filter**
- Changed from redundant `('DOWNLOAD_FROM_S3','DOWNLOAD_FROM_S3')`
- To clean: `'DOWNLOAD_FROM_S3'`

### 4. **Enhanced Error Messages**
```sql
PRINT 'Error submitting ' + @file_name + ': ' + ERROR_MESSAGE();
```
Added context about which file failed.

## Verification

After running the fixed procedure, verify downloads are recorded:

```sql
-- Check initial submissions
SELECT run_id, file_name, lifecycle, task_id, submitted_at, task_info
FROM django.S3_Download_Tracking
ORDER BY submitted_at DESC;

-- Check for pending tasks
SELECT * FROM django.S3_Download_Tracking
WHERE lifecycle = 'SUBMITTED_PENDING_TASK_ID';

-- Check for failures
SELECT run_id, file_name, lifecycle, task_info
FROM django.S3_Download_Tracking
WHERE lifecycle = 'SUBMIT_FAILED'
ORDER BY submitted_at DESC;
```

## Additional Recommendations

1. **Increase Wait Time if Needed**: If tasks are still not being captured, increase the WAITFOR DELAY from 2 seconds to 5 seconds
2. **Add Retry Logic**: Consider adding a retry mechanism for SUBMITTED_PENDING_TASK_ID status
3. **Monitor RDS Task Status**: Regularly monitor `msdb.dbo.rds_fn_task_status()` to understand task registration timing
4. **Add Logging**: Consider adding more detailed logging at each stage for troubleshooting

## Testing Steps

1. Clear any old test records from `django.S3_Download_Tracking`
2. Run: `EXEC django.usp_Download_And_Load_S3_Files;`
3. Check that all 38 files have tracking records with appropriate lifecycle status
4. Verify no records have NULL lifecycle or task_id (unless status is SUBMITTED_PENDING_TASK_ID)

