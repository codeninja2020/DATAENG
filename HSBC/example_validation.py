#!/usr/bin/env python3
"""
Example: Advanced Validation Scenarios
Demonstrates various validation patterns and use cases.
"""

import pandas as pd
from typing import Dict, List, Any

# Example 1: Simple validation dictionary
SIMPLE_VALIDATION = {
    'user_id': {
        'required': True,
        'not_null': True,
        'data_type': 'int'
    },
    'username': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 3,
        'max_length': 50
    }
}

# Example 2: Validation with custom logic
def validate_age_range(value: Any) -> bool:
    """Age must be between 18 and 120"""
    try:
        age = int(value)
        return 18 <= age <= 120
    except:
        return False

def validate_status(value: Any) -> bool:
    """Status must be one of allowed values"""
    return value in ['active', 'inactive', 'pending', 'suspended']

ADVANCED_VALIDATION = {
    'member_id': {
        'required': True,
        'not_null': True,
        'data_type': 'int'
    },
    'age': {
        'required': True,
        'not_null': True,
        'data_type': 'int',
        'custom_validator': validate_age_range
    },
    'status': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'custom_validator': validate_status
    },
    'balance': {
        'required': False,
        'not_null': False,
        'data_type': 'float'
    }
}

# Example 3: Create sample data with known issues
def create_test_data() -> pd.DataFrame:
    """Create sample data with various validation issues"""
    data = {
        'member_id': [1, 2, 3, None, 5, 6, 'ABC', 8],
        'age': [25, 17, 45, 30, 150, 25, 35, None],
        'status': ['active', 'pending', 'deleted', 'active', 'inactive', '', 'suspended', 'active'],
        'balance': [100.50, 200.00, -50.00, 75.25, 0, 1000, 'invalid', 500.00]
    }
    return pd.DataFrame(data)

# Example 4: Validate and report
def demo_validation():
    """Demonstrate validation on sample data"""
    from streamhsbc import validate_row, validate_chunk

    df = create_test_data()

    print("="*80)
    print("VALIDATION EXAMPLE: Row-by-Row Validation Against Dictionary")
    print("="*80)

    print("\n📊 Sample Data (8 rows with intentional issues):")
    print(df.to_string())

    print(f"\n\n📋 Validation Rules Applied:")
    for field, rules in ADVANCED_VALIDATION.items():
        rule_desc = []
        if rules.get('required'): rule_desc.append('REQUIRED')
        if rules.get('not_null'): rule_desc.append('NOT NULL')
        if rules.get('data_type'): rule_desc.append(f"TYPE={rules['data_type']}")
        if rules.get('custom_validator'): rule_desc.append('CUSTOM_CHECK')
        print(f"  • {field:15s} {' | '.join(rule_desc)}")

    print("\n" + "="*80)
    print("VALIDATION RESULTS - Row by Row")
    print("="*80 + "\n")

    valid_count = 0
    invalid_count = 0

    for idx, row in df.iterrows():
        is_valid, errors = validate_row(row, idx, ADVANCED_VALIDATION)

        if is_valid:
            valid_count += 1
            print(f"✓ Row {idx}: VALID - member_id={row['member_id']}, age={row['age']}, status='{row['status']}'")
        else:
            invalid_count += 1
            print(f"✗ Row {idx}: INVALID - {len(errors)} error(s)")
            for error in errors:
                print(f"    → {error}")
        print()

    # Chunk validation summary
    print("="*80)
    print("CHUNK VALIDATION SUMMARY")
    print("="*80)

    results = validate_chunk(df, ADVANCED_VALIDATION, chunk_number=1)

    print(f"\nTotal rows:     {results['total_rows']}")
    print(f"✓ Valid rows:   {results['valid_rows']} ({results['valid_rows']/results['total_rows']*100:.1f}%)")
    print(f"✗ Invalid rows: {results['invalid_rows']} ({results['invalid_rows']/results['total_rows']*100:.1f}%)")

    print(f"\n🎯 Valid row indices: {results['valid_indices']}")
    print(f"❌ Invalid row indices: {results['invalid_indices']}")

    # Separate valid and invalid dataframes
    valid_df = df.loc[results['valid_indices']]
    invalid_df = df.loc[results['invalid_indices']]

    print("\n" + "="*80)
    print("VALID ROWS READY FOR DATABASE LOAD")
    print("="*80)
    print(valid_df.to_string())

    print("\n" + "="*80)
    print("INVALID ROWS REQUIRING CORRECTION")
    print("="*80)
    print(invalid_df.to_string())

if __name__ == '__main__':
    demo_validation()

