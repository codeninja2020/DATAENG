"""
Validation configuration for member_details data.
Define field validation rules here.
"""

import re
from typing import Any


def validate_email(value: Any) -> bool:
    """Validate email format"""
    if not isinstance(value, str):
        return False
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(email_pattern, value))


def validate_postcode(value: Any) -> bool:
    """Validate UK postcode format"""
    if not isinstance(value, str):
        return False
    # UK postcode pattern (simplified)
    postcode_pattern = r'^[A-Z]{1,2}[0-9]{1,2}[A-Z]?\s?[0-9][A-Z]{2}$'
    return bool(re.match(postcode_pattern, value.upper().strip()))


def validate_phone(value: Any) -> bool:
    """Validate phone number (basic check)"""
    if not isinstance(value, str):
        return False
    # Remove spaces, dashes, parentheses
    clean_phone = re.sub(r'[\s\-()]', '', value)
    # Should be 10-15 digits, optionally starting with +
    return bool(re.match(r'^\+?[0-9]{10,15}$', clean_phone))


# Define validation rules for member_details
MEMBER_DETAILS_VALIDATION = {
    # Primary key field - CIN (Customer Identification Number)
    'CIN': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 1,
        'description': 'Customer Identification Number (unique member identifier)'
    },

    # Segment field
    'Segment': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'description': 'Member segment'
    },

    # Name fields
    'first_name': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 1,
        'max_length': 100,
        'description': 'First name of member'
    },

    'last_name': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 1,
        'max_length': 100,
        'description': 'Last name of member'
    },

    # Address fields
    'address_line_1': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 1,
        'max_length': 500,
        'description': 'Primary address line'
    },

    'post_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'max_length': 20,
        'description': 'Postal code'
    },

    'country_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'max_length': 10,
        'description': 'Country code'
    },

    # Optional fields
    'email_address': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'min_length': 5,
        'max_length': 254,
        'custom_validator': validate_email,
        'description': 'Valid email address'
    },

    'date_of_birth': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'description': 'Member date of birth'
    },

    'title_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'description': 'Title code (Mr, Mrs, etc.)'
    },

    'gender_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'description': 'Gender code'
    },
}


# Alternative: Minimal validation (adjust based on actual fields in your file)
MINIMAL_VALIDATION = {
    'CIN': {'required': True, 'not_null': True, 'data_type': 'str'},
    #'Segment': {'required': True, 'not_null': True, 'data_type': 'str'},
    'first_name': {'required': True, 'not_null': True, 'data_type': 'str'},
    'last_name': {'required': True, 'not_null': True, 'data_type': 'str'},
    #'address_line_1': {'required': True, 'not_null': True, 'data_type': 'str'},
}

