--Creates all tables in the Django schema if they do not already exist.
-- This script is intended to be idempotent and can be run multiple times without causing errors.

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'articles')
BEGIN
    CREATE TABLE [Django].[articles]
    [id]          INT             NOT NULL,
    [title]       NVARCHAR (4000) NULL,
    [slug]        NVARCHAR (4000) NULL,
    [tags]        NVARCHAR (4000) NULL,
    [created]     DATETIME2 (0)   NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL
);


END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'brands')
BEGIN
    CREATE TABLE [Django].[brands]
    [id]          INT             NOT NULL,
    [name]        NVARCHAR (4000) NULL,
    [vendor_id]   NVARCHAR (4000) NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL
);


END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'dining_celebrity_chefs')
BEGIN
    CREATE TABLE [Django].[dining_celebrity_chefs]
    [id]          INT             NOT NULL,
    [name]        NVARCHAR (4000) NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL
);


END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'dining_cuisine')
BEGIN
    CREATE TABLE [Django].[dining_cuisine]
    [id]          INT             NOT NULL,
    [name]        NVARCHAR (4000) NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL
);


END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'dining_hot_table_bookings')
BEGIN
    CREATE TABLE [Django].[dining_hot_table_bookings]
    [id]           INT             NOT NULL,
    [member_id]    INT             NULL,
    [author_id]    INT             NULL,
    [hot_table_id] INT             NULL,
    [status]       NVARCHAR (4000) NULL,
    [created]      DATETIME2 (0)   NULL,
    [inserted_on]  DATETIME        NOT NULL,
    [processid]    VARCHAR (255)   NULL
);


END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'dining_hot_tables')
BEGIN
    CREATE TABLE [Django].[dining_hot_tables]
    [id]                    INT             NOT NULL,
    [name]                  NVARCHAR (4000) NULL,
    [id2]                   NVARCHAR (4000) NULL,
    [number_of_seats]       INT             NULL,
    [available_at_datetime] DATETIME        NULL,
    [inserted_on]           DATETIME        NOT NULL,
    [processid]             VARCHAR (255)   NULL
);


END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'dining_restaurant_benefits')
BEGIN
    CREATE TABLE [Django].[dining_restaurant_benefits]
    [id]            INT             NOT NULL,
    [name]          NVARCHAR (4000) NULL,
    [benefit_code]  NVARCHAR (4000) NULL,
    [restaurant_id] INT             NULL,
    [inserted_on]   DATETIME        NOT NULL,
    [processid]     VARCHAR (255)   NULL
);



END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'dining_restaurants')
BEGIN
    CREATE TABLE [Django].[dining_restaurants]
    [id]              INT             NOT NULL,
    [name]            NVARCHAR (4000) NULL,
    [latitude]        NVARCHAR (4000) NULL,
    [longitude]       NVARCHAR (4000) NULL,
    [city]            NVARCHAR (4000) NULL,
    [postcode]        NVARCHAR (4000) NULL,
    [country]         NVARCHAR (4000) NULL,
    [cuisine]         NVARCHAR (4000) NULL,
    [location_id]     NVARCHAR (64)   NULL,
    [price_indicator] NVARCHAR (4000) NULL,
    [rating]          NVARCHAR (4000) NULL,
    [website]         NVARCHAR (4000) NULL,
    [vendor_id]       INT             NULL,
    [tags]            NVARCHAR (4000) NULL,
    [inserted_on]     DATETIME        NOT NULL,
    [processid]       VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_dining_restaurants_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);


END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'email_templates')
BEGIN
    CREATE TABLE [Django].[email_templates]
    [name]        NVARCHAR (4000) NOT NULL,
    [campaign_id] INT             NOT NULL,
    [name1]       NVARCHAR (4000) NOT NULL,
    [sites]       NVARCHAR (4000) NULL,
    [subject]     NVARCHAR (4000) NOT NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'entertainment_artists')
BEGIN
    CREATE TABLE [Django].[entertainment_artists]
    [id]            INT             NOT NULL,
    [name]          NVARCHAR (4000) NULL,
    [see_artist_id] NVARCHAR (64)   NULL,
    [created_at]    DATETIME2 (0)   NULL,
    [inserted_on]   DATETIME        NOT NULL,
    [processid]     VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'entertainment_bookings')
BEGIN
    CREATE TABLE [Django].[entertainment_bookings]
    [id]                 INT             NOT NULL,
    [member_id]          INT             NULL,
    [author_id]          INT             NULL,
    [name]               NVARCHAR (4000) NULL,
    [status]             NVARCHAR (4000) NULL,
    [delivery_method_id] INT             NULL,
    [performance_id]     INT             NULL,
    [payment_status]     NVARCHAR (4000) NULL,
    [external_id]        INT             NULL,
    [provider]           NVARCHAR (4000) NULL,
    [created]            DATETIME2 (0)   NULL,
    [inserted_on]        DATETIME        NOT NULL,
    [processid]          VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'entertainment_delivery_methods')
BEGIN
    CREATE TABLE [Django].[entertainment_delivery_methods]
    [id]             INT             NOT NULL,
    [name]           NVARCHAR (4000) NULL,
    [price_currency] NVARCHAR (4000) NULL,
    [provider]       NVARCHAR (4000) NULL,
    [inserted_on]    DATETIME        NOT NULL,
    [processid]      VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'entertainment_event_tags')
BEGIN
    CREATE TABLE [Django].[entertainment_event_tags]
    [id]          INT           NOT NULL,
    [event_id]    INT           NULL,
    [tag_id]      INT           NULL,
    [inserted_on] DATETIME      NULL,
    [processid]   VARCHAR (255) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_id]
    ON [Django].[entertainment_event_tags];

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'entertainment_events')
BEGIN
    CREATE TABLE [Django].[entertainment_events]
    [id]                     INT             NOT NULL,
    [name]                   NVARCHAR (4000) NULL,
    [category]               NVARCHAR (4000) NULL,
    [number_of_performances] NVARCHAR (4000) NULL,
    [popularity]             NVARCHAR (4000) NULL,
    [currency]               NVARCHAR (4000) NULL,
    [active]                 NVARCHAR (4000) NULL,
    [created]                DATETIME2 (0)   NULL,
    [chosen_tags]            NVARCHAR (4000) NULL,
    [inserted_on]            DATETIME        NOT NULL,
    [processid]              VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_entertainment_events_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'entertainment_performances')
BEGIN
    CREATE TABLE [Django].[entertainment_performances]
    [id]                    INT             NOT NULL,
    [event_id]              INT             NULL,
    [venue_id]              INT             NULL,
    [start_local_date_time] NVARCHAR (4000) NULL,
    [ten_direct_vendor_id]  INT             NULL,
    [inserted_on]           DATETIME        NOT NULL,
    [processid]             VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_entertainment_performances_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'entertainment_ticket_types')
BEGIN
    CREATE TABLE [Django].[entertainment_ticket_types]
    [id]                  INT             NOT NULL,
    [performance_id]      INT             NULL,
    [see_offer_id]        NVARCHAR (40)   NULL,
    [see_price_id]        NVARCHAR (40)   NULL,
    [price]               DECIMAL (20, 3) NULL,
    [price_currency]      NVARCHAR (4000) NULL,
    [face_price]          DECIMAL (20, 3) NULL,
    [face_price_currency] NVARCHAR (4000) NULL,
    [inserted_on]         DATETIME        NOT NULL,
    [processid]           VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_entertainment_ticket_types_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'entertainment_venues')
BEGIN
    CREATE TABLE [Django].[entertainment_venues]
    [id]           INT             NOT NULL,
    [name]         NVARCHAR (4000) NULL,
    [longitude]    DECIMAL (9, 6)  NULL,
    [latitude]     DECIMAL (9, 6)  NULL,
    [country]      NVARCHAR (4000) NULL,
    [postcode]     NVARCHAR (4000) NULL,
    [location_id]  NVARCHAR (36)   NULL,
    [see_venue_id] INT             NULL,
    [inserted_on]  DATETIME        NOT NULL,
    [processid]    VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_entertainment_venues_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'interest_id_entertainment_events')
BEGIN
    CREATE TABLE [Django].[interest_id_entertainment_events]
    [primary_interest_id] INT           NOT NULL,
    [inserted_on]         DATETIME      NULL,
    [processid]           VARCHAR (255) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_id]
    ON [Django].[interest_id_entertainment_events];

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'load_stat')
BEGIN
    CREATE TABLE [Django].[load_stat]
    [process_id]         UNIQUEIDENTIFIER NULL,
    [process_start_time] DATETIME         NULL,
    [process_end_time]   DATETIME         NULL,
    [process_status]     VARCHAR (100)    NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'location_cities')
BEGIN
    CREATE TABLE [Django].[location_cities]
    [id]                           NVARCHAR (36)   NOT NULL,
    [name]                         NVARCHAR (4000) NULL,
    [geoname_id]                   NVARCHAR (MAX)  NULL,
    [ivector_connect_geo_level_id] INT             NULL,
    [ivector_connect_id]           INT             NULL,
    [ivector_connect_unique_code]  NVARCHAR (4000) NULL,
    [administrative_subdivision]   NVARCHAR (4000) NULL,
    [country]                      NVARCHAR (4000) NULL,
    [inserted_on]                  DATETIME        NOT NULL,
    [processid]                    VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'location_countries')
BEGIN
    CREATE TABLE [Django].[location_countries]
    [id]                           NVARCHAR (50)   NOT NULL,
    [name]                         NVARCHAR (4000) NULL,
    [geoname_id]                   NVARCHAR (4000) NULL,
    [ivector_connect_geo_level_id] NVARCHAR (4000) NULL,
    [ivector_connect_id]           NVARCHAR (4000) NULL,
    [ivector_connect_unique_code]  NVARCHAR (4000) NULL,
    [alpha3_code]                  NVARCHAR (4000) NULL,
    [iso_code]                     NVARCHAR (4000) NULL,
    [inserted_on]                  DATETIME        NOT NULL,
    [processid]                    VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'location_locationtags')
BEGIN
    CREATE TABLE [Django].[location_locationtags]
    [id]                           NVARCHAR (50)   NOT NULL,
    [name]                         NVARCHAR (4000) NULL,
    [geoname_id]                   INT             NULL,
    [ivector_connect_geo_level_id] INT             NULL,
    [ivector_connect_id]           INT             NULL,
    [ivector_connect_unique_code]  NVARCHAR (4000) NULL,
    [inserted_on]                  DATETIME        NOT NULL,
    [processid]                    VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_benefit_memberbenefit_sites')
BEGIN
    CREATE TABLE [Django].[member_benefit_memberbenefit_sites]
    [id]               INT           NULL,
    [memberbenefit_id] INT           NULL,
    [site_id]          INT           NULL,
    [Inserted_On]      DATETIME      NULL,
    [ProcessID]        VARCHAR (255) NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_benefit_memberbenefit_tags')
BEGIN
    CREATE TABLE [Django].[member_benefit_memberbenefit_tags]
    [id]               INT           NULL,
    [memberbenefit_id] INT           NULL,
    [tag_id]           INT           NULL,
    [Inserted_On]      DATETIME      NULL,
    [ProcessID]        VARCHAR (255) NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_benefits')
BEGIN
    CREATE TABLE [Django].[member_benefits]
    [id]                          INT                NOT NULL,
    [name]                        NVARCHAR (4000)    NULL,
    [available_from]              DATETIMEOFFSET (7) NULL,
    [available_until]             DATETIMEOFFSET (7) NULL,
    [brand_id]                    INT                NULL,
    [location_id]                 NVARCHAR (50)      NULL,
    [status]                      NVARCHAR (4000)    NULL,
    [url_redemption]              NVARCHAR (4000)    NULL,
    [online_redemption_code]      NVARCHAR (4000)    NULL,
    [in_store_redemption]         NVARCHAR (4000)    NULL,
    [has_redemption_phone_number] NVARCHAR (4000)    NULL,
    [phone_number]                NVARCHAR (4000)    NULL,
    [chosen_tags]                 NVARCHAR (MAX)     NULL,
    [sites]                       NVARCHAR (MAX)     NULL,
    [inserted_on]                 DATETIME           NOT NULL,
    [processid]                   VARCHAR (255)      NULL,
    [ten_maid_offer_id]           VARCHAR (4000)     NULL,
    [rating]                      INT                NULL,
    [alternate_rating]            INT                NULL,
    CONSTRAINT [PK_Django_member_benefits_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_details')
BEGIN
    CREATE TABLE [Django].[member_details]
    [id]                INT             NOT NULL,
    [member_profile_id] INT             NULL,
    [tag]               NVARCHAR (4000) NULL,
    [tag_id]            INT             NULL,
    [inserted_on]       DATETIME        NOT NULL,
    [processid]         VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_events')
BEGIN
    CREATE TABLE [Django].[member_events]
    [id]                          INT             NOT NULL,
    [name]                        NVARCHAR (4000) NULL,
    [latitude]                    DECIMAL (9, 6)  NULL,
    [longitude]                   DECIMAL (9, 6)  NULL,
    [city]                        NVARCHAR (4000) NULL,
    [country]                     NVARCHAR (4000) NULL,
    [postcode]                    NVARCHAR (4000) NULL,
    [type]                        NVARCHAR (4000) NULL,
    [adult_ticket_price]          MONEY           NULL,
    [adult_ticket_price_currency] NVARCHAR (4000) NULL,
    [child_ticket_price]          MONEY           NULL,
    [child_ticket_price_currency] NVARCHAR (4000) NULL,
    [chosen_tags]                 NVARCHAR (4000) NULL,
    [sites]                       NVARCHAR (4000) NULL,
    [supplier]                    NVARCHAR (4000) NULL,
    [vendor_id]                   INT             NULL,
    [inserted_on]                 DATETIME        NOT NULL,
    [processid]                   VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_member_events_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_events_bookings')
BEGIN
    CREATE TABLE [Django].[member_events_bookings]
    [id]               INT             NOT NULL,
    [event_id]         INT             NULL,
    [member_id]        INT             NULL,
    [event_date]       DATETIME2 (0)   NULL,
    [booked_timestamp] DATETIME2 (0)   NULL,
    [booking_status]   NVARCHAR (4000) NULL,
    [inserted_on]      DATETIME        NOT NULL,
    [processid]        VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_events_dates')
BEGIN
    CREATE TABLE [Django].[member_events_dates]
    [id]             INT             NOT NULL,
    [event_id]       INT             NULL,
    [local_datetime] NVARCHAR (4000) NULL,
    [inserted_on]    DATETIME        NOT NULL,
    [processid]      VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_events_memberevent')
BEGIN
    CREATE TABLE [Django].[member_events_memberevent]
    [id]                  INT            NOT NULL,
    [name]                NVARCHAR (255) NULL,
    [type]                NVARCHAR (255) NULL,
    [supplier]            NVARCHAR (255) NULL,
    [primary_interest_id] INT            NULL,
    [inserted_on]         DATETIME       NULL,
    [processid]           VARCHAR (255)  NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_id]
    ON [Django].[member_events_memberevent];

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_events_memberevent_tags')
BEGIN
    CREATE TABLE [Django].[member_events_memberevent_tags]
    [id]             INT           NOT NULL,
    [memberevent_id] INT           NULL,
    [tag_id]         INT           NULL,
    [inserted_on]    DATETIME      NULL,
    [processid]      VARCHAR (255) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_id]
    ON [Django].[member_events_memberevent_tags];

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'member_profiles')
BEGIN
    CREATE TABLE [Django].[member_profiles]
    [user_id]                                 INT                NULL,
    [created]                                 DATETIME2 (0)      NULL,
    [member_id]                               INT                NULL,
    [ten_maid_corporate_scheme_id]            INT                NULL,
    [title]                                   NVARCHAR (4000)    NULL,
    [email]                                   NVARCHAR (4000)    NULL,
    [birth_date]                              DATE               NULL,
    [gender]                                  NVARCHAR (4000)    NULL,
    [country_of_citizenship]                  NVARCHAR (4000)    NULL,
    [preferred_contact_method]                NVARCHAR (4000)    NULL,
    [client_opt_in]                           NVARCHAR (4000)    NULL,
    [ten_opt_in]                              NVARCHAR (4000)    NULL,
    [terms_and_conditions_accepted_timestamp] DATETIMEOFFSET (7) NULL,
    [ten_maid_in_sync]                        NVARCHAR (4000)    NULL,
    [password_email_sent_datetime]            DATETIMEOFFSET (7) NULL,
    [enable_calendar_invites]                 NVARCHAR (4000)    NULL,
    [enable_booking_reminders]                NVARCHAR (4000)    NULL,
    [login_from_new_device_emails]            NVARCHAR (4000)    NULL,
    [two_step_login]                          NVARCHAR (4000)    NULL,
    [weekly_newsletter]                       NVARCHAR (4000)    NULL,
    [member_events_invite]                    NVARCHAR (4000)    NULL,
    [dining_interest]                         NVARCHAR (4000)    NULL,
    [music_tickets]                           NVARCHAR (4000)    NULL,
    [theatre_interest]                        NVARCHAR (4000)    NULL,
    [art_exhibitions]                         NVARCHAR (4000)    NULL,
    [events_for_children]                     NVARCHAR (4000)    NULL,
    [other_attractions]                       NVARCHAR (4000)    NULL,
    [accessory_events_clothing]               NVARCHAR (4000)    NULL,
    [travel_inspiration]                      NVARCHAR (4000)    NULL,
    [hotel_openings]                          NVARCHAR (4000)    NULL,
    [flight_sales]                            NVARCHAR (4000)    NULL,
    [viewed_tour]                             NVARCHAR (4000)    NULL,
    [account_activated]                       NVARCHAR (4000)    NULL,
    [password_hash]                           NVARCHAR (4000)    NULL,
    [inserted_on]                             DATETIME           NOT NULL,
    [processid]                               VARCHAR (255)      NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'partners')
BEGIN
    CREATE TABLE [Django].[partners]
    [id]          INT             NOT NULL,
    [name]        NVARCHAR (4000) NULL,
    [link]        NVARCHAR (4000) NULL,
    [chosen_tags] NVARCHAR (4000) NULL,
    [sites]       NVARCHAR (4000) NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_partners_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'sites')
BEGIN
    CREATE TABLE [Django].[sites]
    [site_id]     INT             NULL,
    [site_name]   NVARCHAR (4000) NULL,
    [inserted_on] DATETIME        NOT NULL,
    [processid]   VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'tags')
BEGIN
    CREATE TABLE [Django].[tags]
    [id]                     INT             NOT NULL,
    [name]                   NVARCHAR (4000) NULL,
    [tag_group]              NVARCHAR (4000) NULL,
    [articles_module]        NVARCHAR (4000) NULL,
    [travel_module]          NVARCHAR (4000) NULL,
    [dining_module]          NVARCHAR (4000) NULL,
    [entertainment_module]   NVARCHAR (4000) NULL,
    [member_benefits_module] NVARCHAR (4000) NULL,
    [member_events_module]   NVARCHAR (4000) NULL,
    [inserted_on]            DATETIME        NOT NULL,
    [processid]              VARCHAR (255)   NULL,
    [interest_type]          NVARCHAR (4000) NULL,
    [is_interest]            NVARCHAR (5)    NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'travel_airport_groups')
BEGIN
    CREATE TABLE [Django].[travel_airport_groups]
    [id]                 INT             NOT NULL,
    [name]               NVARCHAR (4000) NULL,
    [ivector_connect_id] INT             NULL,
    [airports]           NVARCHAR (4000) NULL,
    [inserted_on]        DATETIME        NOT NULL,
    [processid]          VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'travel_airports')
BEGIN
    CREATE TABLE [Django].[travel_airports]
    [id]                 INT             NOT NULL,
    [name]               NVARCHAR (4000) NULL,
    [ivector_connect_id] NVARCHAR (4000) NULL,
    [iata_code]          NVARCHAR (4000) NULL,
    [location_id]        NVARCHAR (50)   NULL,
    [latitude]           DECIMAL (9, 6)  NULL,
    [longitude]          DECIMAL (9, 6)  NULL,
    [inserted_on]        DATETIME        NOT NULL,
    [processid]          VARCHAR (255)   NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'travel_car_hire_depots')
BEGIN
    CREATE TABLE [Django].[travel_car_hire_depots]
    [id]                 INT                NOT NULL,
    [latitude]           DECIMAL (9, 6)     NULL,
    [longitude]          DECIMAL (9, 6)     NULL,
    [ivector_connect_id] NVARCHAR (4000)    NULL,
    [name]               NVARCHAR (4000)    NULL,
    [vendor_id]          INT                NULL,
    [location_id]        NVARCHAR (50)      NULL,
    [created]            DATETIMEOFFSET (7) NULL,
    [deleted]            DATETIMEOFFSET (7) NULL,
    [inserted_on]        DATETIME           NOT NULL,
    [processid]          VARCHAR (255)      NULL
);

﻿
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'Django' AND TABLE_NAME = 'travel_hotels')
BEGIN
    CREATE TABLE [Django].[travel_hotels]
    [id]                  INT             NOT NULL,
    [name]                NVARCHAR (4000) NULL,
    [ivector_connect_id]  NVARCHAR (4000) NULL,
    [latitude]            DECIMAL (9, 6)  NULL,
    [longitude]           DECIMAL (9, 6)  NULL,
    [star_rating]         NVARCHAR (4000) NULL,
    [location_id]         NVARCHAR (4000) NULL,
    [city]                NVARCHAR (4000) NULL,
    [country]             NVARCHAR (4000) NULL,
    [expedia_id]          INT             NULL,
    [benefit_collections] NVARCHAR (4000) NULL,
    [inserted_on]         DATETIME        NOT NULL,
    [processid]           VARCHAR (255)   NULL
);


END
