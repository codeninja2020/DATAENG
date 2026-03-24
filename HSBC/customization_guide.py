#!/usr/bin/env python3
"""
CUSTOMIZATION GUIDE
How to add your own validation rules and custom validators.
"""

from typing import Any
import re
from datetime import datetime

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EXAMPLE 1: Simple Field Requirements
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BASIC_VALIDATION = {
    # Integer primary key
    'customer_id': {
        'required': True,
        'not_null': True,
        'data_type': 'int'
    },

    # String with length constraints
    'customer_name': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 2,
        'max_length': 100
    },

    # Optional numeric field
    'account_balance': {
        'required': False,
        'not_null': False,
        'data_type': 'float'
    },

    # Date field
    'registration_date': {
        'required': True,
        'not_null': True,
        'data_type': 'date'
    }
}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EXAMPLE 2: Custom Validators for Business Rules
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def validate_account_number(value: Any) -> bool:
    """Account number must be 8 digits"""
    if not isinstance(value, (str, int)):
        return False
    account_str = str(value).strip()
    return bool(re.match(r'^\d{8}$', account_str))


def validate_membership_tier(value: Any) -> bool:
    """Membership tier must be one of allowed values"""
    allowed_tiers = ['Gold', 'Silver', 'Bronze', 'Platinum', 'Standard']
    return str(value).strip() in allowed_tiers


def validate_credit_score(value: Any) -> bool:
    """Credit score must be 300-850 (US FICO range)"""
    try:
        score = int(value)
        return 300 <= score <= 850
    except (ValueError, TypeError):
        return False


def validate_positive_amount(value: Any) -> bool:
    """Amount must be positive"""
    try:
        amount = float(value)
        return amount > 0
    except (ValueError, TypeError):
        return False


def validate_past_date(value: Any) -> bool:
    """Date must be in the past (not future)"""
    try:
        import pandas as pd
        date_val = pd.to_datetime(value)
        return date_val < pd.Timestamp.now()
    except:
        return False


def validate_iso_country_code(value: Any) -> bool:
    """Country code must be 2-letter ISO code"""
    if not isinstance(value, str):
        return False
    # Simplified check - in production, compare against ISO 3166-1 alpha-2 list
    return bool(re.match(r'^[A-Z]{2}$', value.upper()))


ADVANCED_BUSINESS_RULES = {
    'account_number': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'custom_validator': validate_account_number,
        'description': 'Must be 8-digit account number'
    },

    'membership_tier': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'custom_validator': validate_membership_tier,
        'description': 'Must be valid tier: Gold/Silver/Bronze/Platinum/Standard'
    },

    'credit_score': {
        'required': False,
        'not_null': False,
        'data_type': 'int',
        'custom_validator': validate_credit_score,
        'description': 'FICO score 300-850'
    },

    'loan_amount': {
        'required': True,
        'not_null': True,
        'data_type': 'float',
        'custom_validator': validate_positive_amount,
        'description': 'Must be positive amount'
    },

    'account_open_date': {
        'required': True,
        'not_null': True,
        'data_type': 'date',
        'custom_validator': validate_past_date,
        'description': 'Must be historical date (not future)'
    },

    'country_code': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'custom_validator': validate_iso_country_code,
        'description': 'ISO 3166-1 alpha-2 country code (e.g., GB, US)'
    }
}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EXAMPLE 3: Multiple Validation Sets for Different Tables
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MEMBER_VALIDATION = {
    'member_id': {'required': True, 'not_null': True, 'data_type': 'int'},
    'email': {'required': True, 'not_null': True, 'data_type': 'str', 'min_length': 5},
    'first_name': {'required': True, 'not_null': True, 'data_type': 'str'},
    'last_name': {'required': True, 'not_null': True, 'data_type': 'str'},
}

TRANSACTION_VALIDATION = {
    'transaction_id': {'required': True, 'not_null': True, 'data_type': 'int'},
    'member_id': {'required': True, 'not_null': True, 'data_type': 'int'},
    'amount': {'required': True, 'not_null': True, 'data_type': 'float',
               'custom_validator': validate_positive_amount},
    'transaction_date': {'required': True, 'not_null': True, 'data_type': 'date'},
}

LOCATION_VALIDATION = {
    'location_id': {'required': True, 'not_null': True, 'data_type': 'int'},
    'country_code': {'required': True, 'not_null': True, 'data_type': 'str',
                     'custom_validator': validate_iso_country_code},
    'latitude': {'required': False, 'not_null': False, 'data_type': 'float'},
    'longitude': {'required': False, 'not_null': False, 'data_type': 'float'},
}

# Use appropriate validation for each table:
# validate_chunk(member_chunk, MEMBER_VALIDATION, ...)
# validate_chunk(transaction_chunk, TRANSACTION_VALIDATION, ...)
# validate_chunk(location_chunk, LOCATION_VALIDATION, ...)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# EXAMPLE 4: Lambda Functions for Quick Validators
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LAMBDA_VALIDATION = {
    # Check if value is in allowed list
    'status': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'custom_validator': lambda x: x in ['Active', 'Inactive', 'Pending']
    },

    # Check if value is within range
    'age': {
        'required': True,
        'not_null': True,
        'data_type': 'int',
        'custom_validator': lambda x: 0 <= int(x) <= 120
    },

    # Check if percentage is 0-100
    'discount_percent': {
        'required': False,
        'not_null': False,
        'data_type': 'float',
        'custom_validator': lambda x: 0 <= float(x) <= 100
    },

    # Check if string matches pattern
    'product_code': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'custom_validator': lambda x: bool(re.match(r'^[A-Z]{3}-\d{4}$', str(x)))
    }
}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HOW TO USE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if __name__ == '__main__':
    print("="*80)
    print("CUSTOMIZATION EXAMPLES")
    print("="*80)

    print("\n1️⃣  BASIC VALIDATION (simple field types)")
    for field, rules in BASIC_VALIDATION.items():
        print(f"   • {field:25s} {rules}")

    print("\n2️⃣  ADVANCED BUSINESS RULES (custom validators)")
    for field, rules in ADVANCED_BUSINESS_RULES.items():
        desc = rules.get('description', '')
        print(f"   • {field:25s} → {desc}")

    print("\n3️⃣  MULTIPLE VALIDATION SETS (different tables)")
    print(f"   • MEMBER_VALIDATION:      {len(MEMBER_VALIDATION)} fields")
    print(f"   • TRANSACTION_VALIDATION: {len(TRANSACTION_VALIDATION)} fields")
    print(f"   • LOCATION_VALIDATION:    {len(LOCATION_VALIDATION)} fields")

    print("\n4️⃣  LAMBDA VALIDATORS (quick inline validators)")
    print(f"   • Status check:      {LAMBDA_VALIDATION['status']['custom_validator']}")
    print(f"   • Age range check:   {LAMBDA_VALIDATION['age']['custom_validator']}")
    print(f"   • Pattern matching:  {LAMBDA_VALIDATION['product_code']['custom_validator']}")

    print("\n" + "="*80)
    print("HOW TO CUSTOMIZE FOR YOUR DATA")
    print("="*80)

    print("""
STEP 1: Open validation_config.py

STEP 2: Copy one of these examples above

STEP 3: Modify field names and rules to match your data

STEP 4: Test with: python3 test_validation.py

STEP 5: Use in production with streamhsbc.py

EXAMPLES OF CUSTOM VALIDATORS YOU CAN ADD:
  • Credit card validation (Luhn algorithm)
  • IBAN validation
  • Currency code validation (ISO 4217)
  • Reference number format checking
  • Cross-field validation (e.g., end_date > start_date)
  • Database lookup validation (check FK exists)
  • Regex pattern matching
  • Enum/list membership checks
  • Range validation
  • Conditional validation (if field X, then field Y required)
    """)

    print("\n" + "="*80)
    print("✅ Your validation system is ready to customize!")
    print("="*80)

