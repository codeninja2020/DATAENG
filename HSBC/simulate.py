#!/usr/bin/env python3
"""
Script to generate 1 million test records similar to member_details.txt
"""
import random
import csv
from datetime import datetime, timedelta

# Sample data pools
titles = ["MR", "MRS", "MS", "DR", "MISS", "Mr", "Mrs", "Ms", "Dr"]
first_names = [
    "PAUL", "JAMES", "MILO", "HILARY", "SUJATA", "Anderson", "Raymond", "Andy",
    "John", "Sarah", "Michael", "Emma", "David", "Jessica", "Robert", "Lisa",
    "William", "Jennifer", "Richard", "Michelle", "Thomas", "Karen", "Charles",
    "Nancy", "Daniel", "Betty", "Matthew", "Helen", "Anthony", "Sandra", "Mark",
    "Donna", "Donald", "Carol", "Steven", "Ruth", "Paul", "Sharon", "Andrew",
    "Laura", "Joshua", "Deborah", "Kenneth", "Maria", "Kevin", "Patricia"
]
last_names = [
    "SHIPMAN", "MARTIN", "MINDBENDER", "PECKHAM", "DUMMY", "Rich", "Doe",
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
    "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez",
    "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Lee",
    "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez",
    "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright"
]
gender_codes = ["M", "F", ""]
segments = ["1", "2"]
new_joiner = ["0", "1"]
language_code = "BCP 47"

# Address components
street_numbers = list(range(1, 999))
street_names = [
    "Bridge Rd", "Main St", "Lake Dr", "Oak Ave", "Elm St", "Park Blvd",
    "Maple Dr", "Hill Rd", "Pine St", "River Rd", "Cedar Ln", "Washington St",
    "First Ave", "Second St", "Broadway", "Market St", "Church St", "Mill Rd"
]
units = ["Unit", "Suite", "Apt", "Floor"]
cities = [
    "Golden Heights", "Westwood", "Port Richmond", "Springfield", "Riverside",
    "Fairview", "Madison", "Georgetown", "Franklin", "Clinton", "Salem",
    "Burlington", "Manchester", "Oxford", "Newport", "Ashland"
]
states = [
    "FL", "PA", "KS", "CA", "NY", "TX", "OH", "IL", "MI", "GA", "NC", "VA",
    "MA", "WA", "AZ", "TN", "IN", "MO", "MD", "WI", "MN", "CO", "AL", "SC"
]
country_codes = ["", "GB", "US", "CA", "AU", "NZ", "IE"]
postcodes_uk = ["10ZA4C", "SW1A 1AA", "M1 1AE", "B33 8TH", "CR2 6XH", "DN55 1PT"]
postcodes_us = ["10ZA4C", "43 G4K", "12345", "90210", "10001", "77001", "60601"]

# Email domains
email_domains = [
    "hotmail.com", "gmail.com", "yahoo.com", "hsbc.com", "verba.ltd",
    "fake.com", "test.com", "example.com", "mail.com", "email.com"
]

def generate_cin():
    """Generate a random CIN number"""
    # Mix of numeric CINs and alphanumeric ones
    if random.random() < 0.9:
        return str(random.randint(100000000, 9999999999))
    else:
        prefix = "OIMBOS"
        number = random.randint(10000000, 99999999)
        return f"{prefix}{number}"

def generate_email(first_name, last_name):
    """Generate a random email or empty string"""
    if random.random() < 0.3:  # 30% no email
        return ""

    domain = random.choice(email_domains)
    name_part = random.choice([
        f"{first_name.lower()}.{last_name.lower()}",
        f"{first_name[:1].lower()}{last_name.lower()}",
        f"{first_name.lower()}{random.randint(1, 999)}",
        f"test{random.randint(1000, 9999)}",
        f"deven{random.randint(1, 999)}"
    ])
    return f"{name_part}@{domain}"

def generate_date_of_birth():
    """Generate a date of birth or empty string"""
    if random.random() < 0.95:  # 95% no DOB in source data
        return ""

    # Generate DOB between 18 and 80 years ago
    start_date = datetime.now() - timedelta(days=80*365)
    end_date = datetime.now() - timedelta(days=18*365)
    random_days = random.randint(0, (end_date - start_date).days)
    dob = start_date + timedelta(days=random_days)
    return dob.strftime("%Y-%m-%d")

def generate_address():
    """Generate address components"""
    street_num = random.choice(street_numbers)
    street_name = random.choice(street_names)

    # Some addresses have additional details
    if random.random() < 0.6:
        unit_type = random.choice(units)
        unit_num = random.randint(1, 500)
        address_line_2 = f" {unit_type} {unit_num}"
    else:
        address_line_2 = " "

    city = random.choice(cities)
    state = random.choice(states)

    # Generate descriptive location
    descriptors = ["East Wing", "West Wing", "Lower Level", "Upper Level", "Third Floor", "Second Floor"]
    building_types = ["Office", "Tower", "Building", "Complex"]

    if random.random() < 0.7:
        descriptor = random.choice(descriptors)
        building = random.choice(building_types)
        town_city = f"{descriptor} {building} {city}"
    else:
        town_city = city

    state_region = f"{city} {state}"

    # Postcode
    country = random.choice(country_codes)
    if country == "GB":
        postcode = random.choice(postcodes_uk)
    else:
        postcode = random.choice(postcodes_us)

    return {
        "address_line_1": f"{street_num} {street_name}",
        "address_line_2": address_line_2,
        "town_city": town_city,
        "state_region": state_region,
        "post_code": postcode,
        "country_code": country
    }

def generate_record():
    """Generate a single member details record"""
    cin = generate_cin()
    segment = random.choice(segments)
    new_join = random.choice(new_joiner)
    title = random.choice(titles)
    first_name = random.choice(first_names)
    last_name = random.choice(last_names)
    gender = random.choice(gender_codes)
    dob = generate_date_of_birth()

    address = generate_address()

    email = generate_email(first_name, last_name)

    return {
        "CIN": cin,
        "Segment": segment,
        "New_joiner": new_join,
        "title_code": title,
        "first_name": first_name,
        "last_name": last_name,
        "gender_code": gender,
        "date_of_birth": dob,
        "address_line_1": address["address_line_1"],
        "address_line_2": address["address_line_2"],
        "town_city": address["town_city"],
        "state_region": address["state_region"],
        "post_code": address["post_code"],
        "country_code": address["country_code"],
        "email_address": email,
        "language_code": language_code
    }

def main():
    """Generate 1 million records and write to file"""
    output_file = "/HSBC/million_details.txt"
    total_records = 1_000_000

    print(f"Starting generation of {total_records:,} records...")
    print(f"Output file: {output_file}")

    fieldnames = [
        "CIN", "Segment", "New_joiner", "title_code", "first_name", "last_name",
        "gender_code", "date_of_birth", "address_line_1", "address_line_2",
        "town_city", "state_region", "post_code", "country_code",
        "email_address", "language_code"
    ]

    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter='|', quotechar='"',
                                quoting=csv.QUOTE_ALL)

        # Write header
        writer.writeheader()

        # Generate and write records
        batch_size = 10000
        for i in range(total_records):
            record = generate_record()
            writer.writerow(record)

            # Progress indicator
            if (i + 1) % batch_size == 0:
                progress = ((i + 1) / total_records) * 100
                print(f"Progress: {i + 1:,} / {total_records:,} ({progress:.1f}%)")

    print(f"\n✓ Successfully generated {total_records:,} records!")
    print(f"✓ File saved to: {output_file}")

if __name__ == "__main__":
    main()

