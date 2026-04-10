"""
Validation configuration for member_details data.
Define field validation rules here.
Apr 26
"""

import re
import math
from typing import Any

def validate_email(value: Any) -> bool:
    """Validate email format"""

    """Email address must comply with the HTML5 
       specification for the email input type as 
       defined by the WHATWG HTML Living Standard."""

    if not isinstance(value, str):
        return False
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(email_pattern, value))


def validate_cin(value: Any) -> bool:
    """Validate CIN as exactly 10 digits"""
    if value is None:
        return False
    if isinstance(value, float) and math.isnan(value):
        return False

    if isinstance(value, (int, float)):
        if isinstance(value, float) and not value.is_integer():
            value_str = str(value).strip()
        else:
            value_str = f"{int(value)}"
    else:
        value_str = str(value).strip()

    return bool(re.fullmatch(r'\d{10}', value_str))


# Define validation rules for member_details (defaults aligned to config.json)
MEMBER_DETAILS_VALIDATION = {
    # Primary key field - CIN (Customer Identification Number)
    'CIN': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 10,
        'max_length': 10,
        'custom_validator': validate_cin,
        'description': 'Customer Identification Number (unique member identifier, 10 digits)'
    },
    'Segment': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'description': 'Member segment',
    },
    'first_name': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 1,
        'max_length': 100,
        'description': 'First name of member',
    },
    'last_name': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 1,
        'max_length': 100,
        'description': 'Last name of member',
    },
    'address_line_1': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 1,
        'max_length': 500,
        'description': 'Primary address line',
    },
    'address_line_2': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'max_length': 500,
        'description': 'Secondary address line',
    },
    'state_region': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'max_length': 100,
        'description': 'State or region',
    },
    'town_city': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'max_length': 100,
        'description': 'Town or city',
    },
    'post_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'max_length': 20,
        'description': 'Postal code',
    },
    'country_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'max_length': 10,
        'description': 'Country code',
    },
    'language_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'max_length': 10,
        'description': 'Language code',
    },
    'email_address': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 5,
        'max_length': 254,
        'custom_validator': validate_email,
        'description': 'Validated email address',
    },
    'date_of_birth': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'description': 'Member date of birth',
    },
    'title_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'description': 'Title code (Dr, Mr, Mrs, etc.)',
    },
    'gender_code': {
        'required': False,
        'not_null': False,
        'data_type': 'str',
        'description': 'Gender code',
    },
    'membership_status': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'description': 'Membership status',
    },
}


# Alternative: Minimal validation (adjust based on actual fields in your file)
MINIMAL_VALIDATION = {
    'CIN': {
        'required': True,
        'not_null': True,
        'data_type': 'str',
        'min_length': 10,
        'max_length': 10,
        'custom_validator': validate_cin,
    },    #'Segment': {'required': True, 'not_null': True, 'data_type': 'str'},
    'first_name': {'required': True, 'not_null': True, 'data_type': 'str'},
    'last_name': {'required': True, 'not_null': True, 'data_type': 'str'},
    #'address_line_1': {'required': True, 'not_null': True, 'data_type': 'str'},
}

