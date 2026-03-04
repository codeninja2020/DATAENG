SELECT mp.user_id, mp.created, mp.member_id,
       mp.ten_maid_corporate_scheme_id, mp.title, mp.email,
       mp.birth_date, mp.gender, mp.citizenship_id
           AS country_of_citizenship,
        mp.preferred_contact_method, mp.client_opt_in,
        mp.ten_opt_in,terms_and_conditions_accepted_timestamp,
        mp.ten_maid_in_sync, mp.password_email_sent_datetime,
        mp.enable_calendar_invites, mp.enable_booking_reminders,
        mp.login_from_new_device_emails, mp.two_step_login,
        mp.weekly_newsletter, mp.member_events_invite,
        mp.dining_interest, mp.music_tickets, mp.theatre_interest,
        mp.art_exhibitions, mp.events_for_children, mp.other_attractions,
        mp.accessory_events_clothing, mp.travel_inspiration,
        mp.hotel_openings, mp.flight_sales, mp.viewed_tour, mp.active_since
            AS account_activated, u.password AS password_hash
FROM member_profile_memberprofile AS mp JOIN authentication_user AS u ON u.id = mp.user_id