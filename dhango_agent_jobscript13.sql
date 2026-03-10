USE TEN_DATAWAREHOUSE;

/*1.TRACKING TABLES*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'django')
    EXEC('CREATE SCHEMA django AUTHORIZATION dbo'); -- create db schema

IF OBJECT_ID('django.S3_Download_Tracking', 'U') IS NULL
BEGIN
    CREATE TABLE django.S3_Download_Tracking
    (
        id               INT IDENTITY(1,1) PRIMARY KEY,
        run_id           UNIQUEIDENTIFIER NOT NULL,
        file_name        NVARCHAR(200) NOT NULL,
        target_schema    SYSNAME NOT NULL,
        target_table     SYSNAME NOT NULL,
        s3_path          NVARCHAR(500) NOT NULL,
        local_path       NVARCHAR(500) NOT NULL,
        task_id          INT ,
        submitted_at     DATETIME NOT NULL DEFAULT GETDATE(),
        completed_at     DATETIME ,
        lifecycle        VARCHAR(50) ,
        task_info        NVARCHAR(MAX)
    );
END;

/*

ALTER TABLE django.S3_Download_Tracking
ALTER COLUMN lifecycle VARCHAR(50);


ALTER TABLE django.S3_Download_Tracking
ALTER COLUMN task_info NVARCHAR(MAX);


ALTER TABLE django.S3_Download_Tracking
ALTER COLUMN completed_at DATETIME;


ALTER TABLE django.S3_Download_Tracking
ALTER COLUMN task_id INT;
*/

IF OBJECT_ID('django.S3_Load_Tracking', 'U') IS NULL
BEGIN
    CREATE TABLE django.S3_Load_Tracking
    (
        id               INT IDENTITY(1,1) PRIMARY KEY,
        run_id           UNIQUEIDENTIFIER NOT NULL,
        file_name        NVARCHAR(200) NOT NULL,
        target_schema    SYSNAME NOT NULL,
        target_table     SYSNAME NOT NULL,
        local_path       NVARCHAR(500) NOT NULL,
        process_id       UNIQUEIDENTIFIER NULL,
        status           VARCHAR(50) NOT NULL,
        rows_inserted    INT,
        error_message    NVARCHAR(MAX) ,
        started_at       DATETIME NOT NULL DEFAULT GETDATE(),
        finished_at      DATETIME
    );
END;



/* Destination tables (created from CSV headers in TP_20260209220038) */
IF OBJECT_ID('django.articles', 'U') IS NULL
CREATE TABLE django.articles (
    id INT PRIMARY KEY,
    title NVARCHAR(500),
    slug NVARCHAR(255),
    tags NVARCHAR(4000),
    created DATETIME,
    inserted_on DATETIME ,
    processid UNIQUEIDENTIFIER ,
    filename NVARCHAR(255)
);



IF OBJECT_ID('django.brands', 'U') IS NULL
CREATE TABLE django.brands (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    vendor_id INT,
    inserted_on DATETIME ,
    processid UNIQUEIDENTIFIER ,
    filename NVARCHAR(255)
);




IF OBJECT_ID('django.dining_celebrity_chefs', 'U') IS NULL
CREATE TABLE django.dining_celebrity_chefs (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);




IF OBJECT_ID('django.dining_cuisine', 'U') IS NULL
CREATE TABLE django.dining_cuisine (
    id INT,
    name NVARCHAR(255),
    inserted_on DATETIME ,
    processid UNIQUEIDENTIFIER ,
    filename NVARCHAR(255)
);




IF OBJECT_ID('django.dining_hot_table_bookings', 'U') IS NULL
CREATE TABLE django.dining_hot_table_bookings (
    id INT PRIMARY KEY,
    member_id INT,
    author_id INT,
    hot_table_id INT,
    status NVARCHAR(50),
    created DATETIME,
    inserted_on DATETIME ,
    processid UNIQUEIDENTIFIER ,
    filename NVARCHAR(255)
);



IF OBJECT_ID('django.dining_hot_tables', 'U') IS NULL
CREATE TABLE django.dining_hot_tables (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    id_2 INT,
    number_of_seats INT,
    available_at_datetime DATETIME,
    inserted_on DATETIME ,
    processid UNIQUEIDENTIFIER ,
    filename NVARCHAR(255)
);




IF OBJECT_ID('django.dining_restaurant_benefits', 'U') IS NULL
CREATE TABLE django.dining_restaurant_benefits (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    benefit_code NVARCHAR(100),
    restaurant_id INT,
    inserted_on DATETIME,
    processid UNIQUEIDENTIFIER,
    filename NVARCHAR(255)
);


IF OBJECT_ID('django.dining_restaurants', 'U') IS NULL
CREATE TABLE django.dining_restaurants (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    latitude FLOAT,
    longitude FLOAT,
    city NVARCHAR(255),
    postcode NVARCHAR(50),
    country NVARCHAR(100),
    cuisine NVARCHAR(255),
    location_id INT,
    price_indicator NVARCHAR(50),
    rating FLOAT,
    website NVARCHAR(500),
    vendor_id INT,
    tags NVARCHAR(4000),
    inserted_on DATETIME ,
    processid UNIQUEIDENTIFIER ,
    filename NVARCHAR(255)
);





IF OBJECT_ID('django.email_templates', 'U') IS NULL
CREATE TABLE django.email_templates (
    name NVARCHAR(255),
    campaign_id NVARCHAR(100),
    name_2 NVARCHAR(255),
    sites NVARCHAR(4000),
    subject NVARCHAR(500),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);



IF OBJECT_ID('django.entertainment_artists', 'U') IS NULL
CREATE TABLE django.entertainment_artists (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    see_artist_id INT,
    created_at DATETIME,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);





IF OBJECT_ID('django.entertainment_bookings', 'U') IS NULL
CREATE TABLE django.entertainment_bookings (
    id INT PRIMARY KEY,
    member_id INT,
    author_id INT,
    name NVARCHAR(255),
    status NVARCHAR(50),
    delivery_method_id INT,
    performance_id INT,
    payment_status NVARCHAR(50),
    external_id NVARCHAR(255),
    provider NVARCHAR(100),
    created DATETIME,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.entertainment_delivery_methods', 'U') IS NULL
CREATE TABLE django.entertainment_delivery_methods (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    price_currency NVARCHAR(10),
    provider NVARCHAR(100),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.entertainment_event_tags', 'U') IS NULL
CREATE TABLE django.entertainment_event_tags (
    id INT PRIMARY KEY,
    event_id INT,
    tag_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.entertainment_events', 'U') IS NULL
CREATE TABLE django.entertainment_events (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    category NVARCHAR(100),
    number_of_performances INT,
    popularity FLOAT,
    currency NVARCHAR(10),
    active BIT,
    created DATETIME,
    chosen_tags NVARCHAR(4000),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.entertainment_performances', 'U') IS NULL
CREATE TABLE django.entertainment_performances (
    id INT PRIMARY KEY,
    event_id INT,
    venue_id INT,
    start_local_date_time DATETIME,
    ten_direct_vendor_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.entertainment_ticket_types', 'U') IS NULL
CREATE TABLE django.entertainment_ticket_types (
    id INT PRIMARY KEY,
    performance_id INT,
    see_offer_id INT,
    see_price_id INT,
    price DECIMAL(18,2),
    price_currency NVARCHAR(10),
    face_price DECIMAL(18,2),
    face_price_currency NVARCHAR(10),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.entertainment_venues', 'U') IS NULL
CREATE TABLE django.entertainment_venues (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    longitude FLOAT,
    latitude FLOAT,
    country NVARCHAR(100),
    postcode NVARCHAR(50),
    location_id INT,
    see_venue_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.interest_id_entertainment_events', 'U') IS NULL
CREATE TABLE django.interest_id_entertainment_events (
    primary_interest_id INT PRIMARY KEY,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.jobs', 'U') IS NULL
CREATE TABLE django.jobs (
    gateway_id INT PRIMARY KEY,
    gateway_status NVARCHAR(50),
    jobid NVARCHAR(50),
    module NVARCHAR(50),
    productid NVARCHAR(50),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.location_cities', 'U') IS NULL
CREATE TABLE django.location_cities (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    geoname_id INT,
    ivector_connect_geo_level_id INT,
    ivector_connect_id INT,
    ivector_connect_unique_code NVARCHAR(50),
    administrative_subdivision NVARCHAR(255),
    country NVARCHAR(100),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.location_countries', 'U') IS NULL
CREATE TABLE django.location_countries (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    geoname_id INT,
    ivector_connect_geo_level_id INT,
    ivector_connect_id INT,
    ivector_connect_unique_code NVARCHAR(50),
    alpha3_code NVARCHAR(3),
    iso_code NVARCHAR(2),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.location_locationtags', 'U') IS NULL
CREATE TABLE django.location_locationtags (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    geoname_id INT,
    ivector_connect_geo_level_id INT,
    ivector_connect_id INT,
    ivector_connect_unique_code NVARCHAR(50),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.member_benefit_memberbenefit_sites', 'U') IS NULL
CREATE TABLE django.member_benefit_memberbenefit_sites (
    id INT PRIMARY KEY,
    memberbenefit_id INT,
    site_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.member_benefit_memberbenefit_tags', 'U') IS NULL
CREATE TABLE django.member_benefit_memberbenefit_tags (
    id INT PRIMARY KEY,
    memberbenefit_id INT,
    tag_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.member_benefits', 'U') IS NULL
CREATE TABLE django.member_benefits (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    available_from DATETIME,
    available_until DATETIME,
    brand_id INT,
    location_id INT,
    status NVARCHAR(50),
    url_redemption NVARCHAR(500),
    online_redemption_code NVARCHAR(100),
    in_store_redemption NVARCHAR(100),
    has_redemption_phone_number BIT,
    phone_number NVARCHAR(50),
    rating FLOAT,
    alternate_rating FLOAT,
    chosen_tags NVARCHAR(4000),
    sites NVARCHAR(4000),
    ten_maid_offer_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.member_events', 'U') IS NULL
CREATE TABLE django.member_events (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    latitude FLOAT,
    longitude FLOAT,
    city NVARCHAR(255),
    country NVARCHAR(100),
    postcode NVARCHAR(50),
    type NVARCHAR(100),
    adult_ticket_price DECIMAL(18,2),
    adult_ticket_price_currency NVARCHAR(10),
    child_ticket_price DECIMAL(18,2),
    child_ticket_price_currency NVARCHAR(10),
    chosen_tags NVARCHAR(4000),
    sites NVARCHAR(4000),
    supplier NVARCHAR(255),
    vendor_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.member_events_bookings', 'U') IS NULL
CREATE TABLE django.member_events_bookings (
    id INT PRIMARY KEY,
    event_id INT,
    member_id INT,
    event_date DATETIME,
    booked_timestamp DATETIME,
    booking_status NVARCHAR(50),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.member_events_dates', 'U') IS NULL
CREATE TABLE django.member_events_dates (
    id INT PRIMARY KEY,
    event_id INT,
    local_datetime DATETIME,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.member_events_memberevent', 'U') IS NULL
CREATE TABLE django.member_events_memberevent (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    type NVARCHAR(100),
    supplier NVARCHAR(255),
    primary_interest_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.member_events_memberevent_tags', 'U') IS NULL
CREATE TABLE django.member_events_memberevent_tags (
    id INT PRIMARY KEY,
    memberevent_id INT,
    tag_id INT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.partners', 'U') IS NULL
CREATE TABLE django.partners (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    link NVARCHAR(500),
    chosen_tags NVARCHAR(4000),
    sites NVARCHAR(4000),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.sites', 'U') IS NULL
CREATE TABLE django.sites (
    site_id INT PRIMARY KEY,
    site_name NVARCHAR(255),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.tags', 'U') IS NULL
CREATE TABLE django.tags (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    tag_group NVARCHAR(255),
    articles_module BIT,
    travel_module BIT,
    dining_module BIT,
    entertainment_module BIT,
    member_benefits_module BIT,
    member_events_module BIT,
    interest_type NVARCHAR(255),
    is_interest BIT,
    created DATETIME,
    modified DATETIME,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.travel_airport_groups', 'U') IS NULL
CREATE TABLE django.travel_airport_groups (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    ivector_connect_id INT,
    airports NVARCHAR(4000),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.travel_airports', 'U') IS NULL
CREATE TABLE django.travel_airports (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    ivector_connect_id INT,
    iata_code NVARCHAR(10),
    location_id INT,
    latitude FLOAT,
    longitude FLOAT,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.travel_car_hire_depots', 'U') IS NULL
CREATE TABLE django.travel_car_hire_depots (
    id INT PRIMARY KEY,
    latitude FLOAT,
    longitude FLOAT,
    ivector_connect_id INT,
    name NVARCHAR(255),
    vendor_id INT,
    location_id INT,
    created DATETIME,
    deleted DATETIME,
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

IF OBJECT_ID('django.travel_hotels', 'U') IS NULL
CREATE TABLE django.travel_hotels (
    id INT PRIMARY KEY,
    name NVARCHAR(255),
    ivector_connect_id INT,
    latitude FLOAT,
    longitude FLOAT,
    star_rating FLOAT,
    location_id INT,
    city NVARCHAR(255),
    country NVARCHAR(100),
    expedia_id INT,
    benefit_collections NVARCHAR(4000),
    inserted_on DATETIME NULL,
    processid UNIQUEIDENTIFIER NULL,
    filename NVARCHAR(255) NULL
);

/* Normalize nullability: PK columns NOT NULL, all other columns NULL */
DECLARE @pkTargets TABLE (table_name SYSNAME, pk_col SYSNAME);
INSERT INTO @pkTargets (table_name, pk_col) VALUES
    ('articles', 'id'),
    ('brands', 'id'),
    ('dining_celebrity_chefs', 'id'),
    ('dining_cuisine', 'id'),
    ('dining_hot_table_bookings', 'id'),
    ('dining_hot_tables', 'id'),
    ('dining_restaurant_benefits', 'id'),
    ('dining_restaurants', 'id'),
    ('entertainment_artists', 'id'),
    ('entertainment_bookings', 'id'),
    ('entertainment_delivery_methods', 'id'),
    ('entertainment_event_tags', 'id'),
    ('entertainment_events', 'id'),
    ('entertainment_performances', 'id'),
    ('entertainment_ticket_types', 'id'),
    ('entertainment_venues', 'id'),
    ('interest_id_entertainment_events', 'primary_interest_id'),
    ('location_cities', 'id'),
    ('location_countries', 'id'),
    ('location_locationtags', 'id'),
    ('member_benefit_memberbenefit_sites', 'id'),
    ('member_benefit_memberbenefit_tags', 'id'),
    ('member_benefits', 'id'),
    ('member_events', 'id'),
    ('member_events_bookings', 'id'),
    ('member_events_dates', 'id'),
    ('member_events_memberevent', 'id'),
    ('member_events_memberevent_tags', 'id'),
    ('partners', 'id'),
    ('sites', 'site_id'),
    ('tags', 'id'),
    ('travel_airport_groups', 'id'),
    ('travel_airports', 'id'),
    ('travel_car_hire_depots', 'id'),
    ('travel_hotels', 'id');

DECLARE @tbl SYSNAME, @pk SYSNAME, @col SYSNAME, @colType NVARCHAR(100), @alter NVARCHAR(MAX), @pkName SYSNAME;

/* Enforce PK column NOT NULL and add PK constraint if missing */
DECLARE pkCur CURSOR FAST_FORWARD FOR SELECT table_name, pk_col FROM @pkTargets;
OPEN pkCur;
FETCH NEXT FROM pkCur INTO @tbl, @pk;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF COL_LENGTH('django.' + @tbl, @pk) IS NOT NULL
    BEGIN
        SELECT TOP 1 @colType =
            CASE
                WHEN ty.name IN ('varchar','char','varbinary','binary') THEN ty.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
                WHEN ty.name IN ('nvarchar','nchar') THEN ty.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length/2 AS VARCHAR(10)) END + ')'
                WHEN ty.name IN ('decimal','numeric') THEN ty.name + '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
                WHEN ty.name IN ('datetime2','datetimeoffset','time') THEN ty.name + '(' + CAST(c.scale AS VARCHAR(10)) + ')'
                ELSE ty.name
            END
        FROM sys.columns c
        JOIN sys.tables t   ON t.object_id = c.object_id
        JOIN sys.schemas s  ON s.schema_id = t.schema_id
        JOIN sys.types ty   ON ty.user_type_id = c.user_type_id
        WHERE s.name = N'django'
          AND t.name = @tbl
          AND c.name = @pk;

        IF @colType IS NOT NULL
        BEGIN
            SET @alter = N'ALTER TABLE django.' + QUOTENAME(@tbl) +
                         N' ALTER COLUMN ' + QUOTENAME(@pk) + N' ' + @colType + N' NOT NULL;';
            EXEC(@alter);
        END;

        SET @pkName = 'PK_' + @tbl;
        IF NOT EXISTS (
            SELECT 1
            FROM sys.key_constraints kc
            WHERE kc.parent_object_id = OBJECT_ID(N'django.' + @tbl)
              AND kc.type = 'PK'
        )
        BEGIN
            EXEC(N'ALTER TABLE django.' + QUOTENAME(@tbl) +
                 N' ADD CONSTRAINT ' + QUOTENAME(@pkName) +
                 N' PRIMARY KEY (' + QUOTENAME(@pk) + N');');
        END
    END
    FETCH NEXT FROM pkCur INTO @tbl, @pk;
END
CLOSE pkCur;
DEALLOCATE pkCur;

/* Relax non-PK columns to NULL (no NOT NULL except PK) */
DECLARE @schema SYSNAME;
DECLARE colCur CURSOR FAST_FORWARD FOR
SELECT s.name AS schema_name, t.name AS table_name, c.name AS col_name,
       CASE
           WHEN ty.name IN ('varchar','char','varbinary','binary') THEN ty.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
           WHEN ty.name IN ('nvarchar','nchar') THEN ty.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length/2 AS VARCHAR(10)) END + ')'
           WHEN ty.name IN ('decimal','numeric') THEN ty.name + '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
           WHEN ty.name IN ('datetime2','datetimeoffset','time') THEN ty.name + '(' + CAST(c.scale AS VARCHAR(10)) + ')'
           ELSE ty.name
       END AS colType
FROM sys.columns c
JOIN sys.tables t   ON t.object_id = c.object_id
JOIN sys.schemas s  ON s.schema_id = t.schema_id
JOIN sys.types ty   ON ty.user_type_id = c.user_type_id
LEFT JOIN @pkTargets pk ON pk.table_name = t.name AND pk.pk_col = c.name
WHERE s.name = N'django'
  AND c.is_computed = 0
  AND (c.is_nullable = 0)
  AND (pk.pk_col IS NULL); -- skip PK columns

OPEN colCur;
FETCH NEXT FROM colCur INTO @schema, @tbl, @col, @colType;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @alter = N'ALTER TABLE django.' + QUOTENAME(@tbl) +
                 N' ALTER COLUMN ' + QUOTENAME(@col) + N' ' + @colType + N' NULL;';
    EXEC(@alter);
    FETCH NEXT FROM colCur INTO @schema, @tbl, @col, @colType;
END
CLOSE colCur;
DEALLOCATE colCur;


-- count num tables created
SELECT COUNT(*)
FROM information_schema.tables
WHERE table_schema = 'django';

-- list tables created
SELECT *
FROM information_schema.tables
WHERE table_schema = 'django';

--preview a table

SELECT *
FROM TEN_DATAWAREHOUSE.django.dining_celebrity_chefs;


/*2. MAIN PROCEDURE*/
CREATE OR ALTER PROCEDURE django.usp_Download_And_Load_S3_Files
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @run_id UNIQUEIDENTIFIER = NEWID();

    DECLARE @baseS3Prefix NVARCHAR(300) =
        'arn:aws:s3:::bi-staging.tenproduct.com/BE_DJANGO_POSTGRES_CSV/TP_20260209220038/';

    DECLARE @baseLocalPrefix NVARCHAR(300) =
        'D:\S3\BE_DJANGO_POSTGRES_CSV\TP_20260209220038\';

    /*File manifest*/
    DECLARE @files TABLE
    (
        file_name     NVARCHAR(200),
        target_schema SYSNAME,
        target_table  SYSNAME
    );

    INSERT INTO @files (file_name, target_schema, target_table)
    VALUES
        ('articles.csv', 'django', 'articles'),
        ('brands.csv', 'django', 'brands'),
        ('dining_celebrity_chefs.csv', 'django', 'dining_celebrity_chefs'),
        ('dining_cuisine.csv', 'django', 'dining_cuisine'),
        ('dining_hot_table_bookings.csv', 'django', 'dining_hot_table_bookings'),
        ('dining_hot_tables.csv', 'django', 'dining_hot_tables'),
        ('dining_restaurant_benefits.csv', 'django', 'dining_restaurant_benefits'),
        ('dining_restaurants.csv', 'django', 'dining_restaurants'),
        ('email_templates.csv', 'django', 'email_templates'),
        ('entertainment_artists.csv', 'django', 'entertainment_artists'),
        ('entertainment_bookings.csv', 'django', 'entertainment_bookings'),
        ('entertainment_delivery_methods.csv', 'django', 'entertainment_delivery_methods'),
        ('entertainment_event_tags.csv', 'django', 'entertainment_event_tags'),
        ('entertainment_events.csv', 'django', 'entertainment_events'),
        ('entertainment_performances.csv', 'django', 'entertainment_performances'),
        ('entertainment_ticket_types.csv', 'django', 'entertainment_ticket_types'),
        ('entertainment_venues.csv', 'django', 'entertainment_venues'),
        ('interest_id_entertainment_events.csv', 'django', 'interest_id_entertainment_events'),
        ('jobs.csv', 'django', 'jobs'),
        ('location_cities.csv', 'django', 'location_cities'),
        ('location_countries.csv', 'django', 'location_countries'),
        ('location_locationtags.csv', 'django', 'location_locationtags'),
        ('member_benefit_memberbenefit_sites.csv', 'django', 'member_benefit_memberbenefit_sites'),
        ('member_benefit_memberbenefit_tags.csv', 'django', 'member_benefit_memberbenefit_tags'),
        ('member_benefits.csv', 'django', 'member_benefits'),
        ('member_events.csv', 'django', 'member_events'),
        ('member_events_bookings.csv', 'django', 'member_events_bookings'),
        ('member_events_dates.csv', 'django', 'member_events_dates'),
        ('member_events_memberevent.csv', 'django', 'member_events_memberevent'),
        ('member_events_memberevent_tags.csv', 'django', 'member_events_memberevent_tags'),
        ('partners.csv', 'django', 'partners'),
        ('sites.csv', 'django', 'sites'),
        ('tags.csv', 'django', 'tags'),
        ('travel_airport_groups.csv', 'django', 'travel_airport_groups'),
        ('travel_airports.csv', 'django', 'travel_airports'),
        ('travel_car_hire_depots.csv', 'django', 'travel_car_hire_depots'),
        ('travel_hotels.csv', 'django', 'travel_hotels');

    /*----------------------------------------------------
      Ensure schema exists
    ----------------------------------------------------*/
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'django')
        EXEC ('CREATE SCHEMA django AUTHORIZATION dbo;');

    /*----------------------------------------------------
      3. SUBMIT DOWNLOADS
    ----------------------------------------------------*/
    DECLARE
        @file_name NVARCHAR(200),
        @target_schema SYSNAME,
        @target_table SYSNAME,
        @s3_path NVARCHAR(500),
        @local_path NVARCHAR(500);

    DECLARE file_cur CURSOR FAST_FORWARD FOR
        SELECT file_name, target_schema, target_table
        FROM @files;

    OPEN file_cur;
    FETCH NEXT FROM file_cur INTO @file_name, @target_schema, @target_table;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @s3_path = @baseS3Prefix + @file_name;
        SET @local_path = @baseLocalPrefix + @file_name;

        INSERT INTO django.S3_Download_Tracking
        (
            run_id, file_name, target_schema, target_table,
            s3_path, local_path
        )
        VALUES
        (
            @run_id, @file_name, @target_schema, @target_table,
            @s3_path, @local_path
        );

        BEGIN TRY
            DECLARE @submit_task_id INT, @task_lifecycle VARCHAR(50), @task_info NVARCHAR(MAX);

            EXEC msdb.dbo.rds_download_from_s3
                 @s3_arn_of_file = @s3_path,
                 @rds_file_path  = @local_path,
                 @overwrite_file = 1;

            SELECT TOP 1
                @submit_task_id = task_id,
                @task_lifecycle = lifecycle,
                @task_info = task_info
            FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
            WHERE task_type IN ('DOWNLOAD_FROM_S3','DOWNLOAD_FROM_S3')
            ORDER BY task_id DESC;

            UPDATE django.S3_Download_Tracking
            SET task_id = @submit_task_id,
                lifecycle = @task_lifecycle,
                task_info = @task_info
            WHERE run_id = @run_id
              AND file_name = @file_name;
        END TRY

        BEGIN CATCH
            UPDATE django.S3_Download_Tracking
            SET lifecycle = 'SUBMIT_FAILED',
                task_info = ERROR_MESSAGE()
            WHERE run_id = @run_id
              AND file_name = @file_name;
        END CATCH;

        FETCH NEXT FROM file_cur INTO @file_name, @target_schema, @target_table;
    END

    CLOSE file_cur;
    DEALLOCATE file_cur;

    /*----------------------------------------------------
      4. WAIT FOR DOWNLOADS TO FINISH
    ----------------------------------------------------*/
    DECLARE @task_id INT, @status VARCHAR(50), @poll_task_info NVARCHAR(MAX);

    DECLARE wait_cur CURSOR FAST_FORWARD FOR
        SELECT task_id, file_name
        FROM django.S3_Download_Tracking
        WHERE run_id = @run_id
          AND task_id IS NOT NULL;

    OPEN wait_cur;
    FETCH NEXT FROM wait_cur INTO @task_id, @file_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @status = 'CREATED';

        WHILE @status IN ('CREATED', 'IN_PROGRESS')
        BEGIN
            WAITFOR DELAY '00:00:05';

            SELECT TOP 1
                @status = lifecycle,
                @poll_task_info = task_info
            FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
            WHERE task_id = @task_id
            ORDER BY task_id DESC;
        END

        UPDATE django.S3_Download_Tracking
        SET lifecycle = @status,
            task_info = @poll_task_info,
            completed_at = GETDATE()
        WHERE run_id = @run_id
          AND task_id = @task_id;

        FETCH NEXT FROM wait_cur INTO @task_id, @file_name;
    END

    CLOSE wait_cur;
    DEALLOCATE wait_cur;

    /*----------------------------------------------------
      5. LOAD SUCCESSFUL DOWNLOADS
    ----------------------------------------------------*/
    DECLARE load_cur CURSOR FAST_FORWARD FOR
        SELECT file_name, target_schema, target_table, local_path
        FROM django.S3_Download_Tracking
        WHERE run_id = @run_id
          AND lifecycle = 'SUCCESS';

    OPEN load_cur;
    FETCH NEXT FROM load_cur INTO @file_name, @target_schema, @target_table, @local_path;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @process_id UNIQUEIDENTIFIER = NEWID();
        DECLARE @full_table NVARCHAR(300) = QUOTENAME(@target_schema) + '.' + QUOTENAME(@target_table);

        BEGIN TRY
            IF OBJECT_ID(@full_table, 'U') IS NULL
                THROW 50001, 'Target table does not exist.', 1;

            INSERT INTO django.S3_Load_Tracking
            (
                run_id, file_name, target_schema, target_table,
                local_path, process_id, status
            )
            VALUES
            (
                @run_id, @file_name, @target_schema, @target_table,
                @local_path, @process_id, 'STARTED'
            );

            DECLARE
                @InsertCols NVARCHAR(MAX),
                @SelectCols NVARCHAR(MAX),
                @RawCols NVARCHAR(MAX),
                @HasIdentity BIT = 0,
                @InsertedOnCol NVARCHAR(200),
                @ProcessIdCol NVARCHAR(200),
                @FileNameCol NVARCHAR(200),
                @sql NVARCHAR(MAX),
                @RowsInserted INT = 0,
                @FieldTerm NVARCHAR(5) = '|',
                @RowTerm NVARCHAR(10) = '0x0A';

            SELECT
                @InsertCols = STRING_AGG(QUOTENAME(c.name), ', ') WITHIN GROUP (ORDER BY c.column_id),
                @SelectCols = STRING_AGG(
                    'TRY_CONVERT(' +
                    CASE
                        WHEN tt.name IN ('varchar','char','varbinary','binary')
                            THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
                        WHEN tt.name IN ('nvarchar','nchar')
                            THEN tt.name + '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length/2 AS VARCHAR(10)) END + ')'
                        WHEN tt.name IN ('decimal','numeric')
                            THEN tt.name + '(' + CAST(c.precision AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
                        WHEN tt.name IN ('datetime2','datetimeoffset','time')
                            THEN tt.name + '(' + CAST(c.scale AS VARCHAR(10)) + ')'
                        ELSE tt.name
                    END +
                    ', NULLIF(' + QUOTENAME(c.name) + ', ''''))'
                , ', ') WITHIN GROUP (ORDER BY c.column_id),
                @RawCols = STRING_AGG(
                    '    ' + QUOTENAME(c.name) + ' NVARCHAR(4000)',
                    ',' + CHAR(13) + CHAR(10)
                ) WITHIN GROUP (ORDER BY c.column_id)
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            JOIN sys.types tt  ON tt.user_type_id = c.user_type_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND c.is_computed = 0
              AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

            IF @InsertCols IS NULL
                THROW 50002, 'No loadable columns found.', 1;

            SELECT @InsertedOnCol = QUOTENAME(c.name)
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND LOWER(c.name) = 'inserted_on';

            SELECT @ProcessIdCol = QUOTENAME(c.name)
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND LOWER(c.name) = 'processid';

            SELECT @FileNameCol = QUOTENAME(c.name)
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND LOWER(c.name) = 'filename';

            SELECT TOP 1 @HasIdentity = 1
            FROM sys.columns c
            JOIN sys.tables t  ON t.object_id = c.object_id
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name = @target_schema
              AND t.name = @target_table
              AND c.is_identity = 1
              AND LOWER(c.name) NOT IN ('inserted_on','processid','filename');

            IF @InsertedOnCol IS NOT NULL
            BEGIN
                SET @InsertCols = @InsertCols + ', ' + @InsertedOnCol;
                SET @SelectCols = @SelectCols + ', GETDATE()';
            END

            IF @ProcessIdCol IS NOT NULL
            BEGIN
                SET @InsertCols = @InsertCols + ', ' + @ProcessIdCol;
                SET @SelectCols = @SelectCols + ', @pid';
            END

            IF @FileNameCol IS NOT NULL
            BEGIN
                SET @InsertCols = @InsertCols + ', ' + @FileNameCol;
                SET @SelectCols = @SelectCols + ', @fname';
            END

            SET @sql = N'
IF OBJECT_ID(''tempdb..#RawData'') IS NOT NULL
    DROP TABLE #RawData;

CREATE TABLE #RawData
(
' + @RawCols + '
);

BULK INSERT #RawData
FROM ''' + REPLACE(@local_path, '''', '''''') + '''
WITH
(
    FIELDTERMINATOR = ' + QUOTENAME(@FieldTerm, '''') + ',
    ROWTERMINATOR   = ' + QUOTENAME(@RowTerm, '''') + ',
    FIRSTROW        = 2,
    CODEPAGE        = ''65001'',
    TABLOCK
);

TRUNCATE TABLE ' + @full_table + ';
' +
CASE WHEN @HasIdentity = 1
     THEN 'SET IDENTITY_INSERT ' + @full_table + ' ON;'
     ELSE ''
END + '
INSERT INTO ' + @full_table + '(' + @InsertCols + ')
SELECT ' + @SelectCols + '
FROM #RawData;

SELECT @out_rows = @@ROWCOUNT;
' +
CASE WHEN @HasIdentity = 1
     THEN 'SET IDENTITY_INSERT ' + @full_table + ' OFF;'
     ELSE ''
END + '
DROP TABLE #RawData;
';

            EXEC sp_executesql
                @sql,
                N'@pid UNIQUEIDENTIFIER, @fname NVARCHAR(260), @out_rows INT OUTPUT',
                @pid = @process_id,
                @fname = @file_name,
                @out_rows = @RowsInserted OUTPUT;

            UPDATE django.S3_Load_Tracking
            SET status = 'SUCCESS',
                rows_inserted = @RowsInserted,
                finished_at = GETDATE()
            WHERE run_id = @run_id
              AND file_name = @file_name;

            BEGIN TRY
                EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = @local_path;
            END TRY
            BEGIN CATCH
                PRINT 'Cleanup warning for ' + @file_name + ': ' + ERROR_MESSAGE();
            END CATCH;
        END TRY
        BEGIN CATCH
            UPDATE django.S3_Load_Tracking
            SET status = 'FAILED',
                error_message = ERROR_MESSAGE(),
                finished_at = GETDATE()
            WHERE run_id = @run_id
              AND file_name = @file_name;

            IF @@ROWCOUNT = 0
            BEGIN
                INSERT INTO django.S3_Load_Tracking
                (
                    run_id, file_name, target_schema, target_table,
                    local_path, process_id, status, error_message, finished_at
                )
                VALUES
                (
                    @run_id, @file_name, @target_schema, @target_table,
                    @local_path, @process_id, 'FAILED', ERROR_MESSAGE(), GETDATE()
                );
            END
        END CATCH;

        FETCH NEXT FROM load_cur INTO @file_name, @target_schema, @target_table, @local_path;
    END

    CLOSE load_cur;
    DEALLOCATE load_cur;

    SELECT @run_id AS run_id;
END;


USE TEN_DATAWAREHOUSE;

EXEC django.usp_Download_And_Load_S3_Files;

SELECT * FROM django.S3_Download_Tracking ORDER BY id DESC;


SELECT  *
FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
WHERE task_type = 'DOWNLOAD_FROM_S3'
ORDER BY task_id DESC;

SELECT * FROM django.S3_Load_Tracking ORDER BY id DESC;

