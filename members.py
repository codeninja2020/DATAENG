import sqlite3

# Connect to SQLite database
conn = sqlite3.connect(':memory:')
cursor = conn.cursor()

# Create member_profiles table
cursor.execute('''
    CREATE TABLE IF NOT EXISTS member_profiles (
        user_id INTEGER PRIMARY KEY,
        created DATETIME,
        member_id INTEGER,
        ten_maid_corporate_scheme_id INTEGER,
        title TEXT,
        email TEXT,
        birth_date DATE,
        gender TEXT,
        citizenship_id INTEGER,
        preferred_contact_method TEXT,
        client_opt_in BOOLEAN,
        ten_opt_in BOOLEAN,
        terms_and_conditions_accepted_timestamp DATETIME,
        ten_maid_in_sync BOOLEAN,
        password_email_sent_datetime DATETIME,
        enable_calendar_invites BOOLEAN,
        enable_booking_reminders BOOLEAN,
        login_from_new_device_emails BOOLEAN,
        two_step_login BOOLEAN,
        weekly_newsletter BOOLEAN,
        member_events_invite BOOLEAN,
        dining_interest BOOLEAN,
        music_tickets BOOLEAN,
        theatre_interest BOOLEAN,
        art_exhibitions BOOLEAN,
        events_for_children BOOLEAN,
        other_attractions BOOLEAN,
        accessory_events_clothing BOOLEAN,
        travel_inspiration BOOLEAN,
        hotel_openings BOOLEAN,
        flight_sales BOOLEAN,
        viewed_tour BOOLEAN,
        active_since DATETIME,
        password_hash TEXT
    )
''')

# Example: Insert sample data
# cursor.execute("INSERT INTO member_profiles (user_id, email) VALUES (1, 'test@example.com')")

# Query the table
cursor.execute('SELECT * FROM member_profiles')
results = cursor.fetchall()
print(f"Found {len(results)} records in member_profiles")

# Close connection
conn.close()

