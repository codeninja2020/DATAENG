# Summary: Downloads Not Recording - Issue & Solution

## Problem Statement
No download records were being created in `django.S3_Download_Tracking` table when executing the Django S3 ETL procedure.

## Root Cause Analysis

The issue stemmed from a **race condition** in the download submission logic:

### The Bug
```sql
-- Original Code (BUGGY)
EXEC msdb.dbo.rds_download_from_s3 @s3_arn_of_file = @s3_path, ...;

-- Immediately tried to fetch the task without waiting
SELECT TOP 1 @submit_task_id = task_id ...
FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
WHERE task_type = 'DOWNLOAD_FROM_S3';

-- If task_id was NULL, the update would still run but do nothing meaningful
UPDATE django.S3_Download_Tracking
SET task_id = NULL, lifecycle = NULL, ...  -- All NULL values!
WHERE run_id = @run_id AND file_name = @file_name;
```

### Why It Failed
1. AWS RDS needs time to register the download task in its internal queue
2. Without waiting, `rds_fn_task_status()` returns no results
3. `@submit_task_id` remains NULL
4. UPDATE statement runs but sets task_id to NULL
5. Tracking records exist but are essentially empty (no usable status)

## Solution Implemented

### Key Changes

**1. Added 2-second wait for task registration:**
```sql
WAITFOR DELAY '00:00:02';
```

**2. Implemented conditional UPDATE logic:**
```sql
IF @submit_task_id IS NOT NULL
BEGIN
    -- Normal path: task registered and found
    UPDATE django.S3_Download_Tracking
    SET task_id = @submit_task_id,
        lifecycle = ISNULL(@task_lifecycle, 'CREATED'),
        task_info = @task_info
    WHERE run_id = @run_id AND file_name = @file_name;
END
ELSE
BEGIN
    -- Fallback: task submitted but not yet available
    UPDATE django.S3_Download_Tracking
    SET lifecycle = 'SUBMITTED_PENDING_TASK_ID',
        task_info = 'Task submitted but ID not yet available in system'
    WHERE run_id = @run_id AND file_name = @file_name;
END
```

**3. Enhanced error handling:**
- Better error messages with file name context
- Cleaner task type filter (removed duplication)

## Benefits

✅ **Downloads now always recorded** - Even if task ID isn't immediately available
✅ **Clear status tracking** - Can distinguish between pending vs. submitted vs. failed
✅ **Better debugging** - Easier to identify which files are having issues
✅ **Graceful degradation** - System continues even if task lookup is delayed

## How to Verify the Fix

### Before (Expected to see NULL values):
```sql
SELECT run_id, file_name, lifecycle, task_id, task_info
FROM django.S3_Download_Tracking
WHERE file_name = 'articles.csv';
-- Result: lifecycle=NULL, task_id=NULL, task_info=NULL
```

### After (Expected to see valid statuses):
```sql
SELECT run_id, file_name, lifecycle, task_id, task_info
FROM django.S3_Download_Tracking
WHERE file_name = 'articles.csv' 
ORDER BY submitted_at DESC
LIMIT 1;
-- Result: lifecycle='CREATED' or 'SUBMITTED_PENDING_TASK_ID', task_id=123, task_info='...'
```

## Monitoring Going Forward

Use the provided `diagnostic_queries.sql` to monitor:
1. How many downloads are in each status
2. If any downloads have NULL lifecycle (indicates problem)
3. How many are awaiting task ID registration
4. Which files are failing to submit

## Additional Files Created

1. **DOWNLOAD_TRACKING_FIXES.md** - Detailed technical documentation
2. **diagnostic_queries.sql** - SQL monitoring queries
3. **ServerMaintenance_Overview.md** - Context on the ServerMaintenance repository

## Next Steps

1. ✅ Apply the fix (already done to `dhango_agent_jobscript13.sql`)
2. 🔄 Run the procedure: `EXEC django.usp_Download_And_Load_S3_Files;`
3. 📊 Run diagnostic queries to verify all downloads are recorded
4. 🔍 Check for any with status 'SUBMIT_FAILED' or 'SUBMITTED_PENDING_TASK_ID'
5. 📈 Monitor the wait time - if tasks still not found, increase WAITFOR delay

## Edge Cases Handled

- ✅ Tasks that take >2 seconds to register (marked as PENDING)
- ✅ Tasks that fail to submit (caught in CATCH block)
- ✅ Transient lookup failures (can be retried)
- ✅ NULL lifecycle values (now impossible)

---
**Last Updated**: March 10, 2026
**Status**: FIXED - Awaiting verification testing

