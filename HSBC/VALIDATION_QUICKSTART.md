# Row Validation Against Mandatory Fields Dictionary - Quick Start

## ✅ Implementation Complete

Your validation system is now fully implemented and tested. Each row in a chunk is validated against a dictionary of mandatory field requirements.

## Key Features Implemented

### 1. **Validation Dictionary Structure**
```python
MANDATORY_FIELDS = {
    'field_name': {
        'required': True,           # Must exist in dataframe
        'not_null': True,           # Cannot be null/empty
        'data_type': 'int',         # int, float, str, date
        'min_length': 5,            # Min string length
        'max_length': 254,          # Max string length
        'custom_validator': func,   # Custom validation function
        'description': 'Help text'  # Documentation
    }
}
```

### 2. **Core Functions**

#### `validate_row(row, row_index, validation_rules)` → `(is_valid, errors)`
Validates a single pandas Series row against the dictionary.

**Returns:**
- `is_valid`: Boolean indicating if row passes all checks
- `errors`: List of error messages with row numbers

#### `validate_chunk(chunk, validation_rules, chunk_number)` → `results_dict`
Validates all rows in a DataFrame chunk.

**Returns dictionary with:**
- `total_rows`, `valid_rows`, `invalid_rows`: Counts
- `errors`: List of all error messages
- `valid_indices`: List of valid row indices
- `invalid_indices`: List of invalid row indices

### 3. **Validation Types Supported**

✅ **Required fields** - Field must exist in columns  
✅ **Not null constraints** - Value cannot be empty/null/whitespace  
✅ **Data type checking** - int, float, str, date validation  
✅ **String length** - min_length and max_length constraints  
✅ **Custom validators** - Any function returning bool  
✅ **Email format** - Built-in email validation  
✅ **UK Postcode** - Built-in postcode validation  
✅ **Phone numbers** - Built-in phone validation  

## Quick Start

### Step 1: Define Your Validation Rules
Edit `validation_config.py`:
```python
MANDATORY_FIELDS = {
    'id': {'required': True, 'not_null': True, 'data_type': 'int'},
    'email': {'required': True, 'not_null': True, 'data_type': 'str', 
              'min_length': 5, 'custom_validator': validate_email},
    # ... add your fields
}
```

### Step 2: Use in Your Processing Script
```python
from streamhsbc import validate_chunk, MANDATORY_FIELDS
import pandas as pd

# Process file in chunks
df_iterator = pd.read_csv('data.txt', sep='|', chunksize=10000)

for i, chunk in enumerate(df_iterator):
    # Validate entire chunk
    results = validate_chunk(chunk, MANDATORY_FIELDS, i+1)
    
    # Separate valid from invalid rows
    valid_chunk = chunk.loc[results['valid_indices']]
    invalid_chunk = chunk.loc[results['invalid_indices']]
    
    # Load only valid rows to database
    if not valid_chunk.empty:
        load_to_database(valid_chunk)
    
    # Log/save invalid rows for review
    if not invalid_chunk.empty:
        invalid_chunk.to_csv(f'errors_chunk_{i}.csv', index=False)
    
    print(f"Chunk {i+1}: {results['valid_rows']} valid, {results['invalid_rows']} invalid")
```

## Test & Verify

### Run the test validation:
```bash
cd /Users/tinashejambo/Documents/DATAENG/HSBC
python3 test_validation.py
```

### Run the example with intentional errors:
```bash
python3 example_validation.py
```

### Process your actual data:
```bash
python3 streamhsbc.py
```

## Files Created

1. ✅ **streamhsbc.py** - Main processing script with validation functions
2. ✅ **validation_config.py** - Validation rules and custom validators
3. ✅ **test_validation.py** - Test script for your data
4. ✅ **example_validation.py** - Advanced example scenarios
5. ✅ **member_details_sample.txt** - Sample test data
6. ✅ **VALIDATION_README.md** - Complete documentation
7. ✅ **VALIDATION_QUICKSTART.md** - This file

## Example Output

```
Processing chunk 1, shape: (10000, 9)
============================================================
Valid rows: 9850
Invalid rows: 150

⚠️  Validation Errors (showing first 10):
  - Row 42: Field 'email' cannot be null/empty
  - Row 57: Field 'email' failed custom validation
  - Row 103: Field 'id' must be integer, got 'ABC'
  - Row 215: Field 'first_name' cannot be null/empty
  ...

✓ 9850 valid rows ready for loading
✗ Invalid rows saved to member_details_errors_chunk_1.csv
```

## Integration with SQL Server

The validation system works seamlessly with your SQL Server load process:

1. **Download files from S3** (using your `dhango_agent_jobscript13.sql`)
2. **Validate chunks in Python** (using this system)
3. **Load only valid rows** via BULK INSERT or pyodbc
4. **Track errors** in separate files for data quality team

## Next Steps

1. ✅ Validation system is ready to use
2. Update `validation_config.py` with your actual field requirements
3. Test with your actual `member_details.txt` file
4. Integrate with your database load process
5. Set up automated error reporting

## Support

The validation functions are:
- ✅ Production-ready
- ✅ Tested with sample data
- ✅ Properly error-handled
- ✅ Chunk-processing optimized
- ✅ Fully documented

You can now validate each row in your chunks against the mandatory fields dictionary!

