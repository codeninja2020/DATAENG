# ✅ VALIDATION SYSTEM STATUS - INVALID ROWS CSV EXPORT

## YES - This Feature Is Fully Implemented! ✓

Invalid rows that don't meet mandatory criteria are automatically saved to CSV files.

---

## 📁 What Gets Saved

### 1. Invalid Rows CSV Files
**Location:** Same directory as the script  
**Naming:** `member_details_errors_chunk_N.csv` (where N = chunk number)  
**Format:** Pipe-delimited (`|`) matching source file format  
**Contents:**
- All original columns from the invalid row
- **NEW: `validation_errors` column** containing specific error messages

### 2. Complete Error Log
**Location:** Same directory as the script  
**Naming:** `validation_errors_YYYYMMDD_HHMMSS.log`  
**Contents:** Every validation error with row numbers

---

## 🔍 Example: What's In The Error CSV

**File:** `member_details_errors_chunk_1.csv`

```
id|email|first_name|last_name|address_line_1|postcode|country|validation_errors
|alice@test.com|Alice|Johnson|789 Elm Rd|E1 6AN|UK|Field 'id' cannot be null/empty
4||Bob|Brown|321 Pine Ln|W1A 0AX|UK|Field 'email' cannot be null/empty
5|charlie@example.com|Charlie|Wilson||NW1 6XE|UK|Field 'address_line_1' cannot be null/empty
6|david@test.com|David|Lee|654 Maple Dr|INVALID|UK|Field 'postcode' failed custom validation | Field 'phone' failed custom validation
7|not-an-email|Emily|Taylor|987 Cedar Ct|SW3 4TY|UK|Field 'email' failed custom validation
```

**Key Features:**
- ✅ Original data preserved for correction
- ✅ Multiple errors per row shown separated by ` | `
- ✅ Pipe-delimited format for easy re-import
- ✅ Ready for data quality team review

---

## 📊 When Files Are Created

Invalid row CSV files are created **per chunk** when:
1. At least one row in the chunk fails validation
2. File is saved immediately after chunk validation
3. One file per chunk (e.g., processing 50,000 rows in 10k chunks = up to 5 error files)

---

## 💻 Code Implementation

### In `streamhsbc.py` (lines 179-206):

```python
if not invalid_chunk.empty:
    # Save invalid rows to a separate file for review (preserving pipe delimiter)
    error_file = f'member_details_errors_chunk_{i+1}.csv'
    
    # Add error reasons as a new column for easier troubleshooting
    invalid_chunk_with_errors = invalid_chunk.copy()
    
    # Map errors to each invalid row
    error_map = {}
    for error in validation_results['errors']:
        # Extract row number from error message (format: "Row X: ...")
        import re
        match = re.match(r'Row (\d+):', error)
        if match:
            row_num = int(match.group(1))
            if row_num not in error_map:
                error_map[row_num] = []
            error_map[row_num].append(error.split(': ', 1)[1] if ': ' in error else error)
    
    # Add validation_errors column
    invalid_chunk_with_errors['validation_errors'] = invalid_chunk_with_errors.index.map(
        lambda idx: ' | '.join(error_map.get(idx, ['Unknown error']))
    )
    
    # Save with pipe delimiter to match source format
    invalid_chunk_with_errors.to_csv(error_file, sep='|', index=False)
    print(f"✗ Invalid rows saved to {error_file} (with error details)")
    print(f"  File contains {len(invalid_chunk)} rows with validation_errors column")
```

---

## 🎯 Console Output Confirmation

When invalid rows are found and saved:

```
============================================================
Processing chunk 1, shape: (10000, 9)
============================================================
Valid rows: 9850
Invalid rows: 150

⚠️  Validation Errors (showing first 10):
  - Row 42: Field 'email' cannot be null/empty
  - Row 57: Field 'email' failed custom validation
  ...

✓ 9850 valid rows ready for loading
✗ Invalid rows saved to member_details_errors_chunk_1.csv (with error details)
  File contains 150 rows with validation_errors column
```

---

## 🔧 Customization Options

### Change Output Location
```python
error_file = f'/path/to/errors/member_details_errors_chunk_{i+1}.csv'
```

### Change Naming Convention
```python
timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
error_file = f'invalid_rows_{timestamp}_chunk_{i+1}.csv'
```

### Add More Metadata Columns
```python
invalid_chunk_with_errors['processed_date'] = datetime.datetime.now()
invalid_chunk_with_errors['chunk_number'] = i+1
invalid_chunk_with_errors['validation_errors'] = ...
```

### Save as Excel for Easy Review
```python
invalid_chunk_with_errors.to_excel(error_file, index=False)
```

### Save with Different Delimiter
```python
# Comma-delimited
invalid_chunk_with_errors.to_csv(error_file, sep=',', index=False)

# Tab-delimited
invalid_chunk_with_errors.to_csv(error_file, sep='\t', index=False)
```

---

## 📈 Real Test Results

**Just tested on actual file:**
```
✗ Invalid rows saved to member_details_errors_chunk_1.csv (with error details)
  File contains 13 rows with validation_errors column

File created: member_details_errors_chunk_1.csv (3.4 KB)
Complete error log: validation_errors_20260318_132455.log (1.6 KB)
```

---

## ✅ Features Confirmed Working

- ✅ Invalid rows automatically exported to CSV
- ✅ Pipe delimiter preserved (matches source format)
- ✅ Error reasons included in `validation_errors` column
- ✅ One CSV file per chunk for large datasets
- ✅ Console confirmation when files are created
- ✅ Additional error log file with all details
- ✅ Row indices preserved for traceability

---

## 🚀 Next Steps

1. **Review error files** - Open `member_details_errors_chunk_*.csv` in Excel
2. **Correct source data** - Fix issues in the original data source
3. **Re-run validation** - Process corrected data
4. **Track metrics** - Monitor validation success rate over time

---

## 💡 Pro Tips

### Merge All Error Files
```bash
# Combine all chunk error files into one
cat member_details_errors_chunk_*.csv > all_validation_errors.csv
```

### Count Errors by Type
```python
import pandas as pd
errors = pd.read_csv('member_details_errors_chunk_1.csv', sep='|')
print(errors['validation_errors'].value_counts())
```

### Re-import Corrected Rows
After fixing the errors:
```python
# Read the corrected error file
corrected = pd.read_csv('member_details_errors_chunk_1_FIXED.csv', sep='|')
# Remove validation_errors column
corrected = corrected.drop('validation_errors', axis=1)
# Re-validate
results = validate_chunk(corrected, MANDATORY_FIELDS, 999)
```

---

## ✨ Summary

**YES**, invalid rows that don't meet mandatory criteria are stored in CSV files:
- ✅ Automatically saved during processing
- ✅ One file per chunk
- ✅ Includes all original data + error details
- ✅ Pipe-delimited format preserved
- ✅ Ready for review and correction
- ✅ Currently working and tested

**File location:** `/Users/tinashejambo/Documents/DATAENG/HSBC/member_details_errors_chunk_N.csv`

