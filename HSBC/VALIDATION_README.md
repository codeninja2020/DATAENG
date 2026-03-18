# Member Details Validation System

## Overview
This validation system validates each row in a data chunk against a dictionary of mandatory field requirements before loading into the database.

## Files

### 1. `validation_config.py`
Defines validation rules as Python dictionaries:

```python
MANDATORY_FIELDS = {
    'field_name': {
        'required': True,      # Field must exist in the dataframe
        'not_null': True,      # Field cannot be null/empty
        'data_type': 'int',    # int, float, str, date
        'min_length': 5,       # Minimum string length
        'max_length': 254,     # Maximum string length
        'custom_validator': func,  # Custom validation function
        'description': 'desc'  # Human-readable description
    }
}
```

**Built-in Custom Validators:**
- `validate_email()` - Validates email format
- `validate_postcode()` - Validates UK postcode format
- `validate_phone()` - Validates phone number format

### 2. `streamhsbc.py`
Main processing script with validation functions:

**Key Functions:**
- `validate_row(row, row_index, validation_rules)` - Validates a single row
- `validate_chunk(chunk, validation_rules, chunk_number)` - Validates entire chunk

### 3. `test_validation.py`
Test script to demonstrate validation with sample data.

## Usage

### Basic Usage
```python
from streamhsbc import validate_chunk, MANDATORY_FIELDS
import pandas as pd

# Process file in chunks
df_iterator = pd.read_csv('member_details.txt', sep='|', chunksize=10000)

for i, chunk in enumerate(df_iterator):
    # Validate the chunk
    results = validate_chunk(chunk, MANDATORY_FIELDS, i+1)
    
    # Get valid/invalid rows
    valid_chunk = chunk.loc[results['valid_indices']]
    invalid_chunk = chunk.loc[results['invalid_indices']]
    
    # Process valid rows (e.g., load to database)
    if not valid_chunk.empty:
        # Load valid_chunk to database
        pass
    
    # Handle invalid rows (e.g., log errors)
    if not invalid_chunk.empty:
        invalid_chunk.to_csv(f'errors_chunk_{i}.csv', index=False)
```

### Run Full Processing
```bash
cd /Users/tinashejambo/Documents/DATAENG/HSBC
python3 streamhsbc.py
```

### Run Validation Test
```bash
cd /Users/tinashejambo/Documents/DATAENG/HSBC
python3 test_validation.py
```

## Validation Results Structure

The `validate_chunk()` function returns a dictionary:

```python
{
    'chunk_number': 1,
    'total_rows': 10000,
    'valid_rows': 9850,
    'invalid_rows': 150,
    'errors': ['Row 5: Field email cannot be null/empty', ...],
    'valid_indices': [0, 1, 2, ...],      # Indices of valid rows
    'invalid_indices': [5, 12, 23, ...]   # Indices of invalid rows
}
```

## Validation Rules Supported

### Data Type Validation
- **int**: Must be convertible to integer
- **float**: Must be numeric
- **str**: String data with optional length constraints
- **date**: Must be parseable as datetime

### Constraint Validation
- **required**: Field must exist in the dataframe columns
- **not_null**: Field value cannot be null, empty string, or whitespace-only
- **min_length**: Minimum string length (after trimming)
- **max_length**: Maximum string length
- **custom_validator**: Custom function that takes value and returns True/False

## Customization

### Add New Validation Rules
Edit `validation_config.py` to add new fields or modify existing rules:

```python
MANDATORY_FIELDS = {
    'member_id': {
        'required': True,
        'not_null': True,
        'data_type': 'int'
    },
    'membership_tier': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'custom_validator': lambda x: x in ['Gold', 'Silver', 'Bronze']
    }
}
```

### Create Custom Validator
Add to `validation_config.py`:

```python
def validate_membership_tier(value: Any) -> bool:
    """Validate membership tier is one of allowed values"""
    allowed_tiers = ['Gold', 'Silver', 'Bronze', 'Platinum']
    return value in allowed_tiers

# Then reference in validation rules
'membership_tier': {
    'custom_validator': validate_membership_tier
}
```

## Error Handling

The system:
1. **Continues processing** even when invalid rows are found
2. **Logs all errors** with row numbers and field names
3. **Saves invalid rows** to separate CSV files for review
4. **Tracks valid indices** so only clean data is loaded
5. **Generates summary statistics** showing success rate

## Integration with SQL Server Load

The validated chunks can be directly loaded using `BULK INSERT` or `pyodbc`:

```python
import pyodbc

conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};...')
cursor = conn.cursor()

for i, chunk in enumerate(df_iterator):
    results = validate_chunk(chunk, MANDATORY_FIELDS, i+1)
    valid_chunk = chunk.loc[results['valid_indices']]
    
    # Insert only valid rows
    for idx, row in valid_chunk.iterrows():
        cursor.execute("""
            INSERT INTO django.member_details 
            (id, email, first_name, last_name, address_line_1, ...)
            VALUES (?, ?, ?, ?, ?, ...)
        """, row['id'], row['email'], row['first_name'], ...)
    
    conn.commit()
```

## Example Output

```
Processing chunk 1, shape: (10000, 12)
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

============================================================
VALIDATION SUMMARY
============================================================
Total valid rows: 98450
Total invalid rows: 1550
Success rate: 98.45%

Complete error log saved to validation_errors_20260318_143022.log
```

## Benefits

1. ✅ **Data Quality Assurance** - Only clean data reaches the database
2. ✅ **Error Tracking** - All validation failures logged with row numbers
3. ✅ **Reprocessing Support** - Invalid rows saved separately for correction
4. ✅ **Performance** - Chunk-based processing handles large files efficiently
5. ✅ **Flexibility** - Easy to add/modify validation rules
6. ✅ **Transparency** - Detailed reporting of validation results

## Troubleshooting

### No errors but zero valid rows
- Check that column names in CSV match validation dictionary keys exactly
- Verify delimiter is correct (pipe `|` by default)

### Custom validators always failing
- Check that custom validator functions are properly imported
- Add debug prints inside custom validators to see input values

### Performance issues with large files
- Increase `chunksize` parameter (default 10000)
- Disable custom validators for non-critical fields
- Use `MINIMAL_VALIDATION` instead of `MEMBER_DETAILS_VALIDATION`

