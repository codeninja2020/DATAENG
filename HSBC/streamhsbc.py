import csv
import pandas as pd
import datetime
import os
from typing import Dict, List, Tuple, Any

# Import validation configurations
try:
    from validation_config import MEMBER_DETAILS_VALIDATION, MINIMAL_VALIDATION
    # Use comprehensive validation by default, or MINIMAL_VALIDATION for lighter checks
    MANDATORY_FIELDS = MEMBER_DETAILS_VALIDATION
except ImportError:
    # Fallback validation if config file not found
    print("Warning: validation_config.py not found. Using fallback validation rules.")
    MANDATORY_FIELDS = {
        'id': {'required': True, 'not_null': True, 'data_type': 'int'},
        'email': {'required': True, 'not_null': True, 'data_type': 'str', 'min_length': 5},
        'first_name': {'required': True, 'not_null': True, 'data_type': 'str', 'min_length': 1},
        'last_name': {'required': True, 'not_null': True, 'data_type': 'str', 'min_length': 1},
        'address_line_1': {'required': True, 'not_null': True, 'data_type': 'str'},
    }

file_path = 'member_details.txt'

def validate_row(row: pd.Series, row_index: int, validation_rules: Dict) -> Tuple[bool, List[str]]:
    """
    Validate a single row against mandatory field requirements.

    Args:
        row: pandas Series representing a single row
        row_index: the index/row number for error reporting
        validation_rules: dictionary of field validation rules

    Returns:
        Tuple of (is_valid: bool, errors: List[str])
    """
    errors = []

    for field, rules in validation_rules.items():
        # Check if required field exists in the dataframe
        if rules.get('required', False):
            if field not in row.index:
                errors.append(f"Row {row_index}: Missing required field '{field}'")
                continue

        value = row.get(field)

        # Check if not_null constraint is violated
        if rules.get('not_null', False):
            if pd.isna(value) or value == '' or (isinstance(value, str) and value.strip() == ''):
                errors.append(f"Row {row_index}: Field '{field}' cannot be null/empty")
                continue

        # Skip further validation if value is null and null is allowed
        if pd.isna(value) or value == '':
            continue

        # Data type validation
        data_type = rules.get('data_type')
        if data_type == 'int':
            try:
                int(value)
            except (ValueError, TypeError):
                errors.append(f"Row {row_index}: Field '{field}' must be integer, got '{value}'")

        elif data_type == 'float':
            try:
                float(value)
            except (ValueError, TypeError):
                errors.append(f"Row {row_index}: Field '{field}' must be numeric, got '{value}'")

        elif data_type == 'date':
            if not pd.api.types.is_datetime64_any_dtype(type(value)):
                try:
                    pd.to_datetime(value)
                except:
                    errors.append(f"Row {row_index}: Field '{field}' must be valid date, got '{value}'")

        # String length validation
        if data_type == 'str' and isinstance(value, str):
            min_length = rules.get('min_length')
            if min_length and len(value.strip()) < min_length:
                errors.append(f"Row {row_index}: Field '{field}' must be at least {min_length} characters")

            max_length = rules.get('max_length')
            if max_length and len(value) > max_length:
                errors.append(f"Row {row_index}: Field '{field}' exceeds max length {max_length}")

        # Custom validation function
        custom_validator = rules.get('custom_validator')
        if custom_validator and callable(custom_validator):
            if not custom_validator(value):
                errors.append(f"Row {row_index}: Field '{field}' failed custom validation")

    return len(errors) == 0, errors


def validate_chunk(chunk: pd.DataFrame, validation_rules: Dict, chunk_number: int) -> Dict[str, Any]:
    """
    Validate all rows in a chunk.

    Returns:
        Dictionary with validation statistics and errors
    """
    results = {
        'chunk_number': chunk_number,
        'total_rows': len(chunk),
        'valid_rows': 0,
        'invalid_rows': 0,
        'errors': [],
        'valid_indices': [],
        'invalid_indices': []
    }

    for idx, row in chunk.iterrows():
        is_valid, errors = validate_row(row, idx, validation_rules)

        if is_valid:
            results['valid_rows'] += 1
            results['valid_indices'].append(idx)
        else:
            results['invalid_rows'] += 1
            results['invalid_indices'].append(idx)
            results['errors'].extend(errors)

    return results


def read_txt_with_delimiter(filename, delimiter):
    data = []
    with open(filename, 'r', newline='', encoding='utf-8') as file:
        # Create a reader object with the specified delimiter
        reader = csv.reader(file, delimiter=delimiter)
        for row in reader:
            data.append(row)
    return data


if __name__ == '__main__':
    # Check if file exists
    if not os.path.exists(file_path):
        print(f"Warning: {file_path} not found. Create sample file first.")
        exit(1)

    # Process file in chunks
    df_iterator = pd.read_csv(file_path, sep='|', engine='python', encoding='utf-8', chunksize=10000)

    total_valid = 0
    total_invalid = 0
    all_errors = []

    for i, chunk in enumerate(df_iterator):
        print(f"\n{'='*60}")
        print(f"Processing chunk {i+1}, shape: {chunk.shape}")
        print(f"{'='*60}")

        # Validate the chunk
        validation_results = validate_chunk(chunk, MANDATORY_FIELDS, i+1)

        # Display results
        print(f"Valid rows: {validation_results['valid_rows']}")
        print(f"Invalid rows: {validation_results['invalid_rows']}")

        if validation_results['errors']:
            print(f"\n⚠️  Validation Errors (showing first 10):")
            for error in validation_results['errors'][:10]:
                print(f"  - {error}")

            if len(validation_results['errors']) > 10:
                print(f"  ... and {len(validation_results['errors']) - 10} more errors")

        # Separate valid and invalid rows
        valid_chunk = chunk.loc[validation_results['valid_indices']]
        invalid_chunk = chunk.loc[validation_results['invalid_indices']]

        if not valid_chunk.empty:
            print(f"\n✓ {len(valid_chunk)} valid rows ready for loading")

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

        total_valid += validation_results['valid_rows']
        total_invalid += validation_results['invalid_rows']
        all_errors.extend(validation_results['errors'])

    # Final summary
    print(f"\n{'='*60}")
    print(f"VALIDATION SUMMARY")
    print(f"{'='*60}")
    print(f"Total valid rows: {total_valid}")
    print(f"Total invalid rows: {total_invalid}")
    print(f"Success rate: {total_valid/(total_valid+total_invalid)*100:.2f}%" if (total_valid+total_invalid) > 0 else "N/A")

    if all_errors:
        print(f"\nTotal errors: {len(all_errors)}")
        # Save all errors to a log file
        error_log = f'validation_errors_{datetime.datetime.now().strftime("%Y%m%d_%H%M%S")}.log'
        with open(error_log, 'w') as f:
            f.write('\n'.join(all_errors))
        print(f"Complete error log saved to {error_log}")


