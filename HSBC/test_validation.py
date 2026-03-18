#!/usr/bin/env python3
"""
Test script to demonstrate row validation against mandatory field dictionary.
This tests the validation functions in streamhsbc.py against sample data.
"""

import pandas as pd
import sys
import os

# Ensure we can import from the same directory
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from streamhsbc import validate_row, validate_chunk, MANDATORY_FIELDS

# Test data file
test_file = 'member_details_sample.txt'

if __name__ == '__main__':
    print("="*80)
    print("VALIDATION TEST - Row-by-Row Validation Against Mandatory Fields Dictionary")
    print("="*80)

    # Display validation rules being used
    print(f"\n📋 Validation Rules (checking {len(MANDATORY_FIELDS)} fields):")
    for field, rules in MANDATORY_FIELDS.items():
        constraints = []
        if rules.get('required'):
            constraints.append('REQUIRED')
        if rules.get('not_null'):
            constraints.append('NOT NULL')
        if rules.get('data_type'):
            constraints.append(f"type={rules['data_type']}")
        if rules.get('min_length'):
            constraints.append(f"min_len={rules['min_length']}")
        if rules.get('max_length'):
            constraints.append(f"max_len={rules['max_length']}")
        if rules.get('custom_validator'):
            constraints.append('CUSTOM_CHECK')

        print(f"  • {field:20s} [{', '.join(constraints)}]")

    # Check if test file exists
    if not os.path.exists(test_file):
        print(f"\n❌ Test file '{test_file}' not found.")
        print("Creating it now would require actual data. Using inline test instead.")

        # Create small inline test dataframe
        test_data = {
            'id': [1, 2, None, 4, 5],
            'email': ['valid@example.com', 'also.valid@test.co.uk', '', 'not-an-email', 'ok@domain.com'],
            'first_name': ['John', 'Jane', 'Alice', '', 'Charlie'],
            'last_name': ['Doe', 'Smith', 'Johnson', 'Brown', 'Wilson'],
            'address_line_1': ['123 Main St', '456 Oak Ave', '789 Elm Rd', '321 Pine Ln', '']
        }
        df = pd.DataFrame(test_data)
        print(f"\n📊 Testing with inline sample data ({len(df)} rows)")
    else:
        # Read from test file
        df = pd.read_csv(test_file, sep='|', engine='python', encoding='utf-8')
        print(f"\n📊 Loaded test file: {test_file} ({len(df)} rows)")

    print(f"\n{'='*80}")
    print("ROW-BY-ROW VALIDATION RESULTS")
    print(f"{'='*80}\n")

    # Validate each row individually for demonstration
    total_valid = 0
    total_invalid = 0

    for idx, row in df.iterrows():
        is_valid, errors = validate_row(row, idx, MANDATORY_FIELDS)

        if is_valid:
            total_valid += 1
            print(f"✓ Row {idx}: VALID")
        else:
            total_invalid += 1
            print(f"✗ Row {idx}: INVALID ({len(errors)} errors)")
            for error in errors:
                print(f"    → {error}")
        print()

    # Also test chunk validation
    print(f"{'='*80}")
    print("CHUNK VALIDATION TEST")
    print(f"{'='*80}\n")

    chunk_results = validate_chunk(df, MANDATORY_FIELDS, chunk_number=1)

    print(f"Chunk size: {chunk_results['total_rows']}")
    print(f"Valid rows: {chunk_results['valid_rows']} ({chunk_results['valid_rows']/chunk_results['total_rows']*100:.1f}%)")
    print(f"Invalid rows: {chunk_results['invalid_rows']} ({chunk_results['invalid_rows']/chunk_results['total_rows']*100:.1f}%)")

    if chunk_results['errors']:
        print(f"\n⚠️  All validation errors:")
        for error in chunk_results['errors']:
            print(f"  - {error}")

    # Show which row indices are valid vs invalid
    print(f"\n✓ Valid row indices: {chunk_results['valid_indices']}")
    print(f"✗ Invalid row indices: {chunk_results['invalid_indices']}")

    print(f"\n{'='*80}")
    print(f"SUMMARY: {total_valid} valid, {total_invalid} invalid out of {len(df)} total rows")
    print(f"{'='*80}")

