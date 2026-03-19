# Processing Time Logging - Summary

## Overview
Successfully implemented comprehensive processing time logging in `streamhsbc.py` for validating large data files.

## What Was Added

### 1. **Import Statement**
```python
import time
```
Added time module to track elapsed time.

### 2. **Script-Level Timing**
- **Start Time**: Captured at the beginning of script execution
- **End Time**: Calculated at the end to show total elapsed time
- **Display Format**: Shows both seconds and minutes

### 3. **Chunk-Level Timing**
Each chunk (10,000 rows) is individually timed:
- Start time captured before chunk processing
- End time calculated after validation
- Shows:
  - Elapsed time in seconds
  - Processing speed (rows/second)

### 4. **Performance Metrics Summary**
At the end of execution, displays:
- **Total processing time** (seconds and minutes)
- **Total rows processed** (with comma formatting)
- **Processing speed** (rows/second)
- **Average time per row** (milliseconds)
- **Start and completion timestamps**

## Sample Output

```
============================================================
Starting validation at 2026-03-19 15:51:42
============================================================

============================================================
Processing chunk 1, shape: (10000, 16)
============================================================
Valid rows: 10000
Invalid rows: 0

✓ 10000 valid rows ready for loading

⏱️  Chunk 1 processing time: 0.31 seconds (31880 rows/sec)

... (processing continues for all chunks) ...

============================================================
VALIDATION SUMMARY
============================================================
Total valid rows: 1,000,000
Total invalid rows: 0
Success rate: 100.00%

============================================================
PERFORMANCE METRICS
============================================================
Total processing time: 27.10 seconds (0.45 minutes)
Total rows processed: 1,000,000
Processing speed: 36,897 rows/second
Average time per row: 0.03 milliseconds
Completed at: 2026-03-19 15:52:10
============================================================
```

## Performance Benchmarks (1 Million Records)

### Test Results:
- **File**: million_details.txt
- **Total Rows**: 1,000,000
- **Chunk Size**: 10,000 rows
- **Total Chunks**: 100
- **Processing Time**: 27.10 seconds (0.45 minutes)
- **Throughput**: ~36,897 rows/second
- **Average Time/Row**: 0.03 milliseconds

### Per-Chunk Performance:
- Average chunk time: ~0.27 seconds
- Chunk speed range: 22,588 - 47,132 rows/sec
- Consistent performance across all chunks

## Validation Features

### Current Validation Rules:
The script validates against these mandatory fields:
- **CIN** (Customer ID) - required, not null
- **Segment** - required, not null
- **first_name** - required, not null, min 1 char
- **last_name** - required, not null, min 1 char
- **address_line_1** - required, not null, min 1 char

### Optional Fields Validated:
- email_address (with format validation)
- post_code
- country_code
- date_of_birth
- title_code
- gender_code

## Error Handling

### Invalid Rows:
- Saved to separate CSV files per chunk: `member_details_errors_chunk_N.csv`
- Includes `validation_errors` column with detailed error messages
- Uses pipe delimiter to match source format

### Error Logging:
- Complete error log saved to: `validation_errors_YYYYMMDD_HHMMSS.log`
- Shows row numbers and specific validation failures

## Usage

### Run Validation:
```bash
cd /Users/tinashejambo/Documents/DATAENG/HSBC
python3 streamhsbc.py
```

### Output Files:
1. **Console Output**: Real-time progress and timing
2. **Error Files**: `member_details_errors_chunk_N.csv` (if validation fails)
3. **Error Log**: `validation_errors_YYYYMMDD_HHMMSS.log` (if errors occur)
4. **Background Log**: `streamhsbc_output.log` (when run in background)

### Run in Background:
```bash
python3 streamhsbc.py > streamhsbc_output.log 2>&1 &
```

## Configuration

### Adjust Validation Rules:
Edit `/Users/tinashejambo/Documents/DATAENG/HSBC/validation_config.py`

Choose validation level:
- `MEMBER_DETAILS_VALIDATION` - Comprehensive validation
- `MINIMAL_VALIDATION` - Basic required fields only

### Adjust Chunk Size:
In `streamhsbc.py`, change the `chunksize` parameter:
```python
df_iterator = pd.read_csv(file_path, sep='|', chunksize=10000)  # Adjust 10000 to desired size
```

## Benefits

1. **Performance Monitoring**: Track processing speed and identify bottlenecks
2. **Progress Tracking**: Real-time updates on processing status
3. **Scalability Testing**: Verify system can handle large datasets
4. **Optimization**: Identify slow chunks or validation rules
5. **Historical Tracking**: Log timestamps for audit trails
6. **Resource Planning**: Estimate time for larger datasets

## Future Enhancements

Potential improvements:
- Add memory usage tracking
- Implement parallel processing for chunks
- Add database load timing (when SQL integration is added)
- Export timing metrics to CSV for analysis
- Add configurable logging levels (DEBUG, INFO, WARNING)
- Implement retry logic with timing

## Related Files

- **Main Script**: `streamhsbc.py`
- **Validation Config**: `validation_config.py`
- **Test Data**: `million_details.txt` (1M records)
- **Original Data**: `member_details.txt`
- **Simulation Script**: `../simulate.py`

---
*Last Updated: March 19, 2026*

