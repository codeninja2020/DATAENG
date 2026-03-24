# Quick Reference: Download Tracking Fix

## TL;DR - What Was Wrong?

**Problem:** Downloads weren't being recorded in the tracking table.

**Root Cause:** Race condition - AWS RDS needs time to register tasks, but the code immediately tried to look up the task ID without waiting.

**Fix:** Added 2-second delay + conditional logic to handle when task ID isn't immediately available.

---

## Files Modified

✅ `/Users/tinashejambo/Documents/DATAENG/dhango_agent_jobscript13.sql`
- Lines 710-754: Fixed download submission logic

---

## Key Code Changes

### BEFORE (Lines 720-725)
```sql
SELECT TOP 1 @submit_task_id = task_id ...
WHERE task_type IN ('DOWNLOAD_FROM_S3','DOWNLOAD_FROM_S3')  -- Redundant
ORDER BY task_id DESC;

UPDATE django.S3_Download_Tracking
SET task_id = @submit_task_id,  -- Might be NULL!
```

### AFTER (Lines 717-740)
```sql
WAITFOR DELAY '00:00:02';  -- NEW: Wait for task registration

SELECT TOP 1 @submit_task_id = task_id ...
WHERE task_type = 'DOWNLOAD_FROM_S3'  -- FIXED: No duplication
ORDER BY task_id DESC;

-- NEW: Conditional logic
IF @submit_task_id IS NOT NULL
BEGIN
    UPDATE ... SET task_id = @submit_task_id ...
END
ELSE
BEGIN
    UPDATE ... SET lifecycle = 'SUBMITTED_PENDING_TASK_ID' ...
END
```

---

## Testing the Fix

### Quick Test
```sql
-- 1. Clear old data (optional)
DELETE FROM django.S3_Download_Tracking WHERE submitted_at < DATEADD(HOUR, -1, GETDATE());

-- 2. Run the procedure
EXEC django.usp_Download_And_Load_S3_Files;

-- 3. Verify results
SELECT COUNT(*) as download_count, COUNT(DISTINCT lifecycle) as unique_statuses
FROM django.S3_Download_Tracking
WHERE submitted_at >= DATEADD(MINUTE, -5, GETDATE());
-- Expected: download_count > 0, All records have lifecycle status
```

### Check for Issues
```sql
-- Should return 0 rows (indicating no problems)
SELECT * FROM django.S3_Download_Tracking
WHERE submitted_at >= DATEADD(MINUTE, -5, GETDATE())
AND lifecycle IS NULL;
```

---

## Monitoring Dashboard Query

```sql
SELECT 
    lifecycle,
    COUNT(*) as count,
    CASE WHEN lifecycle IS NULL THEN '⚠️ PROBLEM' ELSE '✅ OK' END as status
FROM django.S3_Download_Tracking
WHERE submitted_at >= DATEADD(HOUR, -1, GETDATE())
GROUP BY lifecycle
ORDER BY count DESC;
```

---

## Expected Status Values

| Status | Meaning | Action |
|--------|---------|--------|
| `CREATED` | Task registered in AWS | Wait for completion |
| `IN_PROGRESS` | Download running | Wait for completion |
| `SUCCESS` | Download complete | Ready to load |
| `FAILED` | Download failed | Check error_message |
| `SUBMITTED_PENDING_TASK_ID` | Waiting for task ID | Retry or increase delay |
| `SUBMIT_FAILED` | Couldn't submit to AWS | Check error_message |
| `NULL` | **PROBLEM** - No status recorded | Check procedure for errors |

---

## If Problem Persists

1. **Check for SQL errors:**
   ```sql
   -- Look for error messages
   SELECT TOP 10 file_name, lifecycle, task_info
   FROM django.S3_Download_Tracking
   WHERE lifecycle IN ('SUBMIT_FAILED', 'FAILED')
   ORDER BY submitted_at DESC;
   ```

2. **Increase wait time:**
   - Change `WAITFOR DELAY '00:00:02'` to `'00:00:05'`
   - Some systems need more time

3. **Check AWS RDS permissions:**
   - Verify `rds_download_from_s3` procedure exists
   - Verify permissions to call `rds_fn_task_status`

4. **Run diagnostic queries:**
   - Use `diagnostic_queries.sql` for detailed analysis

---

## Related Documentation

- 📄 **DOWNLOAD_TRACKING_FIXES.md** - Technical deep dive
- 📄 **diagnostic_queries.sql** - Monitoring & troubleshooting queries
- 📄 **ISSUE_SUMMARY.md** - Full issue analysis
- 📄 **ServerMaintenance_Overview.md** - Context on other systems

---

**Status**: ✅ FIXED and TESTED
**Last Verified**: March 10, 2026

