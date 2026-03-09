# Django Import — SSIS Package Documentation

> **Project**: Django_Import (SSIS 2019)
> **Purpose**: Import Django web application data (exported as pipe-delimited CSV files from PostgreSQL) into the TenDataWarehouse SQL Server database.
> **Schema**: `[django].*`
> **Last Updated**: February 2026

---

## Table of Contents

1. [Overview](#1-overview)
2. [Project Parameters](#2-project-parameters)
3. [Connection Managers](#3-connection-managers)
4. [Template Pattern — `_Load TEMPLATE.dtsx`](#4-template-pattern--_load-templatedtsx)
5. [Control Package — `Control.dtsx`](#5-control-package--controldtsx)
6. [Control MemberProfile Package — `Control_MemberProfile.dtsx`](#6-control-memberprofile-package--control_memberprofiledtsx)
7. [Representative Load Packages (Detailed)](#7-representative-load-packages-detailed)
8. [Complete Package Summary Table](#8-complete-package-summary-table)
9. [Event Handlers](#9-event-handlers)
10. [Key Observations](#10-key-observations)
11. [Alternative Implementation — SQL Agent Job](#11-alternative-implementation--sql-agent-job)
12. [Alternative Implementation — Python Script](#12-alternative-implementation--python-script)
13. [Alternative Implementation — AWS Glue](#13-alternative-implementation--aws-glue)

---

## 1. Overview

The **Django_Import** SSIS project loads data exported from Ten Group's Django web application (backed by PostgreSQL) into the `TenDataWarehouse` SQL Server database. The source data is exported as **pipe-delimited (`|`) CSV files**, uploaded to an **S3 bucket** (`s3://bi-prod.tenproduct.com`), and then downloaded to a local staging folder before being bulk-loaded into tables under the `[django]` schema.

### Data Domains

| Domain | Entity Count | Examples |
|---|---|---|
| **Dining** | 5 | restaurants, cuisine, celebrity chefs, hot tables, bookings |
| **Entertainment** | 7 | events, artists, bookings, performances, ticket types, venues, delivery methods |
| **Travel** | 4 | hotels, airports, airport groups, car hire depots |
| **Members** | 8 | profiles, details, benefits, events, event bookings, event dates, member events |
| **Content / Config** | 7 | articles, brands, email templates, jobs, partners, sites, tags |
| **Location** | 3 | cities, countries, location tags |
| **Junction Tables** | 4 | member benefit–sites, member benefit–tags, member event–tags, entertainment event–tags |

### High-Level Flow

```
S3 Bucket (bi-prod.tenproduct.com)
  └── BE_DJANGO_POSTGRES_CSV/
        └── {entity}.csv  (pipe-delimited, UTF-8, header row)
              │
              ▼
        AWS CLI (PowerShell) ──► Local staging folder
              │                   S:\TenDataWarehouseDependencies\BE_DJANGO_POSTGRES_CSV\ToBeProcessed
              ▼
        SSIS Flat File Source ──► Derived Column (inserted_on, processid)
              │
              ▼
        OLE DB Destination ──► [django].{entity}  (TenDataWarehouse on LDCSQLPD23)
              │
              ▼
        Archive to S3 ──► s3://bi-prod.tenproduct.com/.../Archive/
```

---

## 2. Project Parameters

Defined in `Project.params`:

| Parameter | Value | Description |
|---|---|---|
| `ProjectKey` | `BE_DJANGO_POSTGRES_CSV` | S3 subfolder key identifying the Django CSV data set |

### Control Package Parameters

| Parameter | Default Value | Description |
|---|---|---|
| `aws2Path` | `C:\TenDataWarehouseDependencies\AWSCLI\AWSCLIV2\aws.exe` | Path to AWS CLI executable |
| `PackageName` | `Load jobs.dtsx` | Default child package name (overridden per task) |
| `ProjectKey` | `BE_DJANGO_POSTGRES_CSV` | S3 folder key for this data set |
| `S3BucketAddress` | `s3://bi-prod.tenproduct.com` | Source S3 bucket URI |
| `S3BucketAddressArchive` | `s3://bi-prod.tenproduct.com` | Archive S3 bucket URI |
| `S3DownloadFolder` | `S:\TenDataWarehouseDependencies` | Local download staging root |

### Load Package Parameters

Each `Load *.dtsx` package exposes two parameters:

| Parameter | Example Value | Description |
|---|---|---|
| `Entity` | `dining_restaurants` | Entity name — drives CSV filename and destination table |
| `S3DownloadFolder` | `S:\TenDataWarehouseDependencies\BE_DJANGO_POSTGRES_CSV\ToBeProcessed` | Local folder containing the CSV files to process |

---

## 3. Connection Managers

### 3.1 DestinationServer_OLEDB (Project-Level)

| Property | Value |
|---|---|
| **Type** | OLE DB (SQLNCLI11.1) |
| **Server** | `LDCSQLPD23` |
| **Database** | `TenDataWarehouse` |
| **Authentication** | Windows Integrated (SSPI) |
| **Retry** | 1 retry, 5 s interval |
| **Auto Translate** | `False` |

### 3.2 Flat File Connection Manager (Package-Level)

Each Load package contains a package-level **Flat File** connection manager named `"Flat File"` with these settings:

| Property | Value |
|---|---|
| **Format** | Delimited |
| **Column Delimiter** | `|` (pipe, `_x007C_`) |
| **Row Delimiter** | `LF` (`_x000A_`) for last column; `CRLF` for header |
| **Header Row** | Yes — column names in first row |
| **Text Qualified** | `True` |
| **Code Page** | 65001 (UTF-8) |
| **Unicode** | `False` |
| **Locale** | 2057 (en-GB) |
| **ConnectionString** | Dynamic via expression: `@[User::FileToProcess]` |

---

## 4. Template Pattern — `_Load TEMPLATE.dtsx`

The `_Load TEMPLATE.dtsx` is the **master blueprint** for all 38 Load packages. Every Load package was cloned from this template and customised only in the flat file column definitions and the `Entity` parameter value.

### 4.1 Package Variables

| Variable | Namespace | Expression | Example Value |
|---|---|---|---|
| `FileName` | User | `@[$Package::Entity] + ".csv"` | `articles.csv` |
| `FileToProcess` | User | _(Set by ForEach loop at runtime)_ | Full file path |
| `ProcessID` | User | _(Set by SQL Task in OnPreExecute)_ | GUID string |
| `TableName` | User | `"django." + @[$Package::Entity]` | `django.articles` |

### 4.2 Control Flow

```
┌─────────────────────────────────────────────────────┐
│  Foreach Loop Container                             │
│  ─ Enumerator: ForEachFileEnumerator                │
│  ─ Directory: @[$Package::S3DownloadFolder]         │
│  ─ FileSpec: @[User::FileName]                      │
│  ─ Maps file path → @[User::FileToProcess]          │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │  Data Flow Task: "Load Data"                  │  │
│  │                                               │  │
│  │  Flat File Source                             │  │
│  │    ↓                                          │  │
│  │  Derived Column Transform                     │  │
│  │    • Inserted_On = GETDATE()                  │  │
│  │    • ProcessID = @[User::ProcessID]           │  │
│  │    ↓                                          │  │
│  │  OLE DB Destination                           │  │
│  │    → Table: User::TableName (django.{entity}) │  │
│  │    → Connection: DestinationServer_OLEDB      │  │
│  │    → OpenRowsetVariable: User::TableName      │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### 4.3 Data Flow Components

1. **Flat File Source** — reads the CSV using the Flat File connection manager
2. **Derived Column Transform** — adds two audit columns:
   - `Inserted_On` = `GETDATE()` (current datetime)
   - `ProcessID` = `@[User::ProcessID]` (GUID identifying the batch run)
3. **OLE DB Destination** — fast-load inserts into `django.{entity}` via `DestinationServer_OLEDB`

### 4.4 How Packages Differ from the Template

Most Load packages add a **Truncate Table** Execute SQL Task *before* the Foreach Loop:

```
Truncate Table  ──►  Foreach Loop Container
  (TRUNCATE TABLE django.{entity};)
```

Some newer packages (`articles`, `_Load TEMPLATE`) omit the truncate step because the Control package performs bulk truncation via the `SQL_TRUNCATE_TABLES` variable.

---

## 5. Control Package — `Control.dtsx`

The main orchestrator package that coordinates the entire ETL process.

### 5.1 Execution Flow

```
Step 1: Get Files from S3
  │  (Execute Process → PowerShell → AWS CLI s3 cp)
  │  Downloads from s3://bi-prod.tenproduct.com/BE_DJANGO_POSTGRES_CSV
  │  to S:\TenDataWarehouseDependencies\
  ▼
Step 2: Delete All Folders Except Latest
  │  (Execute Process → PowerShell)
  │  Keeps only the most recent download folder
  ▼
Step 3: Load Data (Sequence Container)
  │
  └── Parrallel Load (Sequence Container — all 38 child packages run in parallel)
      │
      ├── articles                    → Load articles.dtsx
      ├── brands                      → Load brands.dtsx
      ├── dining_celebrity_chefs      → Load dining_celebrity_chefs.dtsx
      ├── dining_cuisine              → Load dining_cuisine.dtsx
      ├── dining_hot_tables           → Load dining_hot_tables.dtsx
      ├── dining_hot_table_bookings   → Load dining_hot_table_bookings.dtsx
      ├── dining_restaurants          → Load dining_restaurants.dtsx
      ├── dining_restaurant_benefits  → Load dining_restaurant_benefits.dtsx
      ├── email_templates             → Load email_templates.dtsx
      ├── entertainment_artists       → Load entertainment_artists.dtsx
      ├── entertainment_bookings      → Load entertainment_bookings.dtsx
      ├── entertainment_delivery_methods → Load entertainment_delivery_methods.dtsx
      ├── entertainment_events        → Load entertainment_events.dtsx
      ├── entertainment_event_tags    → Load entertainment_event_tags.dtsx
      ├── entertainment_performances  → Load entertainment_performances.dtsx
      ├── entertainment_ticket_types  → Load entertainment_ticket_types.dtsx
      ├── entertainment_venues        → Load entertainment_venues.dtsx
      ├── interest_id_entertainment_events → Load interest_id_entertainment_events.dtsx
      ├── jobs                        → Load jobs.dtsx
      ├── location_cities             → Load location_cities.dtsx
      ├── location_countries          → Load location_countries.dtsx
      ├── location_locationtags       → Load location_locationtags.dtsx
      ├── member_benefits             → Load member_benefits.dtsx
      ├── member_benefit_memberbenefit_sites → Load member_benefit_memberbenefit_sites.dtsx
      ├── member_benefit_memberbenefit_tags  → Load member_benefit_memberbenefit_tags.dtsx
      ├── member_details              → Load member_details.dtsx
      ├── member_events               → Load member_events.dtsx
      ├── member_events_bookings      → Load member_events_bookings.dtsx
      ├── member_events_dates         → Load member_events_dates.dtsx
      ├── member_events_memberevent   → Load member_events_memberevent.dtsx
      ├── member_events_memberevent_tags → Load member_events_memberevent_tags.dtsx
      ├── member_profiles             → Load member_profiles.dtsx
      ├── partners                    → Load partners.dtsx
      ├── sites                       → Load sites.dtsx
      ├── tags                        → Load tags.dtsx
      ├── travel_airports             → Load travel_airports.dtsx
      ├── travel_airport_groups       → Load travel_airport_groups.dtsx
      └── travel_car_hire_depots      → Load travel_car_hire_depots.dtsx
  │
  ▼
Step 4: Archive files to s3
  (Execute Process → PowerShell → AWS CLI s3 mv to Archive folder)
```

### 5.2 Key Variables

| Variable | Expression / Value |
|---|---|
| `aws2cliCommandCopy` | `s3 cp s3://bi-prod.tenproduct.com "S:\TenDataWarehouseDependencies" --exclude "Archive/*" --recursive` |
| `aws2cliCommandArchive` | `s3 mv s3://bi-prod.tenproduct.com/BE_DJANGO_POSTGRES_CSV "s3://…/Archive" --recursive --exclude "Archive/*"` |
| `SQL_CREATE_SCHEMA` | `IF NOT EXISTS (…) EXEC('CREATE SCHEMA [django] AUTHORIZATION [dbo]')` |
| `SQL_CREATE_TABLES` | Full DDL for all 32+ tables in `[django]` schema (idempotent `IF NOT EXISTS`) |
| `SQL_TRUNCATE_TABLES` | `TRUNCATE TABLE django.articles; TRUNCATE TABLE django.brands; …` (all 32 tables) |
| `ToBeDeletedPath` | `S:\TenDataWarehouseDependencies\BE_DJANGO_POSTGRES_CSV` |
| `ToBeProcessedPath` | `S:\TenDataWarehouseDependencies\BE_DJANGO_POSTGRES_CSV\ToBeProcessed` |

### 5.3 PowerShell Scripts Referenced

| Script | Purpose |
|---|---|
| `C:\TenDataWarehouseDependencies\AWSCLIcallWithFolderMove.ps1` | Download files from S3 and move to ToBeProcessed folder |
| `C:\TenDataWarehouseDependencies\AWSCLIArchiveFilesInBucket.ps1` | Archive processed files back to S3 |

---

## 6. Control MemberProfile Package — `Control_MemberProfile.dtsx`

A **separate orchestrator** specifically for the `member_profiles` entity. It follows the same pattern as `Control.dtsx` but calls only one child package:

### Execution Flow

```
Step 1: Get Files from S3   (PowerShell → AWS CLI s3 cp)
  ▼
Step 2: Load Data
  └── Parrallel Load
      └── member_profiles → Load member_profiles.dtsx
  ▼
Step 3: Archive files to s3  (PowerShell → AWS CLI s3 mv)
```

This separate orchestrator exists likely because `member_profiles` has a very large dataset (34 CSV columns) and may need to run on a different schedule or with different resource allocation.

---

## 7. Representative Load Packages (Detailed)

### 7.1 Load articles.dtsx

| Property | Value |
|---|---|
| **Entity** | `articles` |
| **Source File** | `articles.csv` |
| **Destination** | `[django].[articles]` |
| **CSV Columns** | `id`, `title`, `slug`, `tags`, `created` |
| **Added Columns** | `inserted_on` (GETDATE), `processid` (GUID) |
| **Truncate Before Load** | No (handled by Control) |

### 7.2 Load dining_restaurants.dtsx

| Property | Value |
|---|---|
| **Entity** | `dining_restaurants` |
| **Source File** | `dining_restaurants.csv` |
| **Destination** | `[django].[dining_restaurants]` |
| **CSV Columns** | `id`, `name`, `latitude`, `longitude`, `city`, `postcode`, `country`, `cuisine`, `location_id`, `price_indicator`, `rating`, `website`, `vendor_id`, `tags` |
| **Added Columns** | `inserted_on`, `processid` |
| **Truncate Before Load** | Yes — `TRUNCATE TABLE django.dining_restaurants;` |

### 7.3 Load entertainment_events.dtsx

| Property | Value |
|---|---|
| **Entity** | `entertainment_events` |
| **Source File** | `entertainment_events.csv` |
| **Destination** | `[django].[entertainment_events]` |
| **CSV Columns** | `id`, `name`, `category`, `number_of_performances`, `popularity`, `currency`, `active`, `created`, `chosen_tags` |
| **Added Columns** | `inserted_on`, `processid` |
| **Truncate Before Load** | Yes |

### 7.4 Load member_details.dtsx

| Property | Value |
|---|---|
| **Entity** | `member_details` |
| **Source File** | `member_details.csv` |
| **Destination** | `[django].[member_details]` |
| **CSV Columns** | `id`, `member_profile_id`, `tag`, `tag_id` |
| **Added Columns** | `inserted_on`, `processid` |
| **Truncate Before Load** | Yes |

### 7.5 Load member_benefits.dtsx

| Property | Value |
|---|---|
| **Entity** | `member_benefits` |
| **Source File** | `member_benefits.csv` |
| **Destination** | `[django].[member_benefits]` |
| **CSV Columns** | `id`, `name`, `available_from`, `available_until`, `brand_id`, `location_id`, `status`, `url_redemption`, `online_redemption_code`, `in_store_redemption`, `has_redemption_phone_number`, `phone_number`, `rating`, `alternate_rating`, `chosen_tags`, `sites`, `ten_maid_offer_id` |
| **Added Columns** | `inserted_on`, `processid` |
| **Truncate Before Load** | Yes |
| **Note** | 17 source columns — one of the wider entities |

### 7.6 Load member_events.dtsx

| Property | Value |
|---|---|
| **Entity** | `member_events` |
| **Source File** | `member_events.csv` |
| **Destination** | `[django].[member_events]` |
| **CSV Columns** | `id`, `name`, `latitude`, `longitude`, `city`, `country`, `postcode`, `type`, `adult_ticket_price`, `adult_ticket_price_currency`, `child_ticket_price`, `child_ticket_price_currency`, `chosen_tags`, `sites`, `supplier`, `vendor_id` |
| **Added Columns** | `inserted_on`, `processid` |
| **Truncate Before Load** | Yes |

### 7.7 Load travel_hotels.dtsx

| Property | Value |
|---|---|
| **Entity** | `travel_hotels` |
| **Source File** | `travel_hotels.csv` |
| **Destination** | `[django].[travel_hotels]` |
| **CSV Columns** | `id`, `name`, `ivector_connect_id`, `latitude`, `longitude`, `star_rating`, `location_id`, `city`, `country`, `expedia_id`, `benefit_collections` |
| **Added Columns** | `inserted_on`, `processid` |
| **Truncate Before Load** | Yes |
| **Note** | Contains a second "Flat File 1" connection manager (airports schema), possibly for reference |

### 7.8 Load sites.dtsx

| Property | Value |
|---|---|
| **Entity** | `sites` |
| **Source File** | `sites.csv` |
| **Destination** | `[django].[sites]` |
| **CSV Columns** | `site_id`, `site_name` |
| **Added Columns** | `inserted_on`, `processid` |
| **Truncate Before Load** | Yes |
| **Note** | Simplest package — only 2 source columns |

### 7.9 Load member_profiles.dtsx

| Property | Value |
|---|---|
| **Entity** | `member_profiles` |
| **Source File** | `member_profiles.csv` |
| **Destination** | `[django].[member_profiles]` |
| **CSV Columns** | `user_id`, `created`, `member_id`, `ten_maid_corporate_scheme_id`, `title`, `email`, `birth_date`, `gender`, `country_of_citizenship`, `preferred_contact_method`, `client_opt_in`, `ten_opt_in`, `terms_and_conditions_accepted_timestamp`, `ten_maid_in_sync`, `password_email_sent_datetime`, `enable_calendar_invites`, `enable_booking_reminders`, `login_from_new_device_emails`, `two_step_login`, `weekly_newsletter`, `member_events_invite`, `dining_interest`, `music_tickets`, `theatre_interest`, `art_exhibitions`, `events_for_children`, `other_attractions`, `accessory_events_clothing`, `travel_inspiration`, `hotel_openings`, `flight_sales`, `viewed_tour`, `account_activated`, `password_hash` |
| **Added Columns** | `inserted_on`, `processid` |
| **Note** | Widest entity — 34 source columns. Has its own dedicated Control package (`Control_MemberProfile.dtsx`) |

### 7.10 Load tags.dtsx

| Property | Value |
|---|---|
| **Entity** | `tags` |
| **Source File** | `tags.csv` |
| **Destination** | `[django].[tags]` |
| **CSV Columns** | `id`, `name`, `tag_group`, `articles_module`, `travel_module`, `dining_module`, `entertainment_module`, `member_benefits_module`, `member_events_module`, `interest_type`, `is_interest`, `created`, `modified` |
| **Added Columns** | `inserted_on`, `processid` |
| **Truncate Before Load** | Yes |
| **Note** | Cross-domain reference table with module flags |

---

## 8. Complete Package Summary Table

### 8.1 All Load Packages

| # | Entity | Source CSV | Destination Table | Source Columns |
|---|---|---|---|---|
| 1 | `articles` | `articles.csv` | `django.articles` | id, title, slug, tags, created |
| 2 | `brands` | `brands.csv` | `django.brands` | id, name, vendor_id |
| 3 | `dining_celebrity_chefs` | `dining_celebrity_chefs.csv` | `django.dining_celebrity_chefs` | id, name |
| 4 | `dining_cuisine` | `dining_cuisine.csv` | `django.dining_cuisine` | id, name |
| 5 | `dining_hot_table_bookings` | `dining_hot_table_bookings.csv` | `django.dining_hot_table_bookings` | id, member_id, author_id, hot_table_id, status, created |
| 6 | `dining_hot_tables` | `dining_hot_tables.csv` | `django.dining_hot_tables` | id, name, id2, number_of_seats, available_at_datetime |
| 7 | `dining_restaurant_benefits` | `dining_restaurant_benefits.csv` | `django.dining_restaurant_benefits` | id, name, benefit_code, restaurant_id |
| 8 | `dining_restaurants` | `dining_restaurants.csv` | `django.dining_restaurants` | id, name, latitude, longitude, city, postcode, country, cuisine, location_id, price_indicator, rating, website, vendor_id, tags |
| 9 | `email_templates` | `email_templates.csv` | `django.email_templates` | name, campaign_id, name1, sites, subject |
| 10 | `entertainment_artists` | `entertainment_artists.csv` | `django.entertainment_artists` | id, name, see_artist_id, created_at |
| 11 | `entertainment_bookings` | `entertainment_bookings.csv` | `django.entertainment_bookings` | id, member_id, author_id, name, status, delivery_method_id, performance_id, payment_status, external_id, provider, created |
| 12 | `entertainment_delivery_methods` | `entertainment_delivery_methods.csv` | `django.entertainment_delivery_methods` | id, name, price_currency, provider |
| 13 | `entertainment_event_tags` | `entertainment_event_tags.csv` | `django.entertainment_event_tags` | id, event_id, tag_id |
| 14 | `entertainment_events` | `entertainment_events.csv` | `django.entertainment_events` | id, name, category, number_of_performances, popularity, currency, active, created, chosen_tags |
| 15 | `entertainment_performances` | `entertainment_performances.csv` | `django.entertainment_performances` | id, event_id, venue_id, start_local_date_time, ten_direct_vendor_id |
| 16 | `entertainment_ticket_types` | `entertainment_ticket_types.csv` | `django.entertainment_ticket_types` | id, performance_id, see_offer_id, see_price_id, price, price_currency, face_price, face_price_currency |
| 17 | `entertainment_venues` | `entertainment_venues.csv` | `django.entertainment_venues` | id, name, longitude, latitude, country, postcode, location_id, see_venue_id |
| 18 | `interest_id_entertainment_events` | `interest_id_entertainment_events.csv` | `django.interest_id_entertainment_events` | primary_interest_id |
| 19 | `jobs` | `jobs.csv` | `django.jobs` | gateway_id, gateway_status, jobid, module, productid |
| 20 | `location_cities` | `location_cities.csv` | `django.location_cities` | id, name, geoname_id, ivector_connect_geo_level_id, ivector_connect_id, ivector_connect_unique_code, administrative_subdivision, country |
| 21 | `location_countries` | `location_countries.csv` | `django.location_countries` | id, name, geoname_id, ivector_connect_geo_level_id, ivector_connect_id, ivector_connect_unique_code, alpha3_code, iso_code |
| 22 | `location_locationtags` | `location_locationtags.csv` | `django.location_locationtags` | id, name, geoname_id, ivector_connect_geo_level_id, ivector_connect_id, ivector_connect_unique_code |
| 23 | `member_benefit_memberbenefit_sites` | `member_benefit_memberbenefit_sites.csv` | `django.member_benefit_memberbenefit_sites` | id, memberbenefit_id, site_id |
| 24 | `member_benefit_memberbenefit_tags` | `member_benefit_memberbenefit_tags.csv` | `django.member_benefit_memberbenefit_tags` | id, memberbenefit_id, tag_id |
| 25 | `member_benefits` | `member_benefits.csv` | `django.member_benefits` | id, name, available_from, available_until, brand_id, location_id, status, url_redemption, online_redemption_code, in_store_redemption, has_redemption_phone_number, phone_number, rating, alternate_rating, chosen_tags, sites, ten_maid_offer_id |
| 26 | `member_details` | `member_details.csv` | `django.member_details` | id, member_profile_id, tag, tag_id |
| 27 | `member_events` | `member_events.csv` | `django.member_events` | id, name, latitude, longitude, city, country, postcode, type, adult_ticket_price, adult_ticket_price_currency, child_ticket_price, child_ticket_price_currency, chosen_tags, sites, supplier, vendor_id |
| 28 | `member_events_bookings` | `member_events_bookings.csv` | `django.member_events_bookings` | id, event_id, member_id, event_date, booked_timestamp, booking_status |
| 29 | `member_events_dates` | `member_events_dates.csv` | `django.member_events_dates` | id, event_id, local_datetime |
| 30 | `member_events_memberevent` | `member_events_memberevent.csv` | `django.member_events_memberevent` | id, name, type, supplier, primary_interest_id |
| 31 | `member_events_memberevent_tags` | `member_events_memberevent_tags.csv` | `django.member_events_memberevent_tags` | id, memberevent_id, tag_id |
| 32 | `member_profiles` | `member_profiles.csv` | `django.member_profiles` | user_id, created, member_id, ten_maid_corporate_scheme_id, title, email, birth_date, gender, country_of_citizenship, preferred_contact_method, client_opt_in, ten_opt_in, terms_and_conditions_accepted_timestamp, ten_maid_in_sync, password_email_sent_datetime, enable_calendar_invites, enable_booking_reminders, login_from_new_device_emails, two_step_login, weekly_newsletter, member_events_invite, dining_interest, music_tickets, theatre_interest, art_exhibitions, events_for_children, other_attractions, accessory_events_clothing, travel_inspiration, hotel_openings, flight_sales, viewed_tour, account_activated, password_hash |
| 33 | `partners` | `partners.csv` | `django.partners` | id, name, link, chosen_tags, sites |
| 34 | `sites` | `sites.csv` | `django.sites` | site_id, site_name |
| 35 | `tags` | `tags.csv` | `django.tags` | id, name, tag_group, articles_module, travel_module, dining_module, entertainment_module, member_benefits_module, member_events_module, interest_type, is_interest, created, modified |
| 36 | `travel_airport_groups` | `travel_airport_groups.csv` | `django.travel_airport_groups` | id, name, ivector_connect_id, airports |
| 37 | `travel_airports` | `travel_airports.csv` | `django.travel_airports` | id, name, ivector_connect_id, iata_code, location_id, latitude, longitude |
| 38 | `travel_car_hire_depots` | `travel_car_hire_depots.csv` | `django.travel_car_hire_depots` | id, latitude, longitude, ivector_connect_id, name, vendor_id, location_id, created, deleted |
| 39 | `travel_hotels` | `travel_hotels.csv` | `django.travel_hotels` | id, name, ivector_connect_id, latitude, longitude, star_rating, location_id, city, country, expedia_id, benefit_collections |

### 8.2 Other Packages

| Package | Type | Purpose |
|---|---|---|
| `Control.dtsx` | Orchestrator | Main control flow — S3 download → parallel load → S3 archive |
| `Control_MemberProfile.dtsx` | Orchestrator | Dedicated orchestrator for member_profiles only |
| `_Load TEMPLATE.dtsx` | Template | Base pattern all Load packages were cloned from |
| `load_data TO BE DELETED.dtsx` | Deprecated | Legacy monolithic load package (marked for deletion) |

---

## 9. Event Handlers

### 9.1 OnPreExecute — Generate ProcessID (Load Packages)

Every Load package's **Foreach Loop Container** has an `OnPreExecute` event handler:

- **Task**: Execute SQL Task — `"Generate ProcessID"`
- **SQL**: `SELECT CONVERT(CHAR(36), NEWID()) AS ProcessID`
- **Connection**: `DestinationServer_OLEDB`
- **Result Set**: Single Row → maps `ProcessID` to `User::ProcessID`
- **Purpose**: Generates a unique GUID for each file iteration to tag all rows loaded in that batch

### 9.2 OnPreValidate — Set Package Name (Control Package)

Each Execute Package Task in the Control package's `Parrallel Load` container has an `OnPreValidate` event handler:

- **Task**: Script Task — `"Set Package Name"`
- **Purpose**: Sets the `User::PackageName` variable to the current child package name (for logging/tracking)

### 9.3 OnPreExecute — File System Task (Control Packages)

The `"Get Files from S3"` and `"Archive files to s3"` tasks have `OnPreExecute` handlers:

- **Task**: File System Task
- **Purpose**: Creates staging directories before the AWS CLI processes run

---

## 10. Key Observations

### Pattern Consistency
- All 38 Load packages follow the identical template pattern: Flat File Source → Derived Column → OLE DB Destination
- Every entity maps 1:1 to a CSV file and a destination table
- The naming convention is completely consistent: `{entity}.csv` → `django.{entity}`

### Load Strategy
- **Full Reload (Truncate & Load)**: Most individual Load packages truncate their target table before loading. The Control package also holds bulk truncate SQL as a fallback
- **No Incremental/CDC**: There is no delta detection — every run is a full replace
- **Parallel Execution**: All 38 packages run in parallel within the `"Parrallel Load"` Sequence Container (note the typo in the original)

### Audit Trail
- `inserted_on` (DATETIME) — timestamp of when the row was loaded
- `processid` (VARCHAR(36)) — GUID identifying the specific load batch
- `django.load_stat` table — tracks process start/end time and status

### Schema Management
- The Control package contains DDL to create the `[django]` schema and all tables (idempotent `IF NOT EXISTS`)
- All tables are in `[django]` schema on `TenDataWarehouse`

### Data Types
- Source CSVs are pipe-delimited (`|`), UTF-8 encoded, with header rows
- Most string columns are `NVARCHAR(4000)` — very generous sizing
- Numeric IDs are `INT`; coordinates use `DECIMAL(9,6)`; prices use `MONEY` or `DECIMAL(20,3)`
- Date columns use `DATETIME2(0)`, `DATETIMEOFFSET(7)`, or `DATE`

### S3 Integration
- Source bucket: `s3://bi-prod.tenproduct.com/BE_DJANGO_POSTGRES_CSV`
- Archive bucket: Same bucket under `…/Archive/` subfolder
- AWS CLI called via PowerShell scripts (`Execute Process` tasks)

### Deprecated Package
- `load_data TO BE DELETED.dtsx` — an older monolithic package that loaded all entities in a single package. Superseded by the modular per-entity approach

---

## 11. Alternative Implementation — SQL Agent Job

### Approach

Replace the SSIS orchestration with a SQL Server Agent Job that uses `BULK INSERT` with a format file, combined with `xp_cmdshell` or PowerShell job steps for S3 interaction.

### Example Job Steps

```sql
-- ============================================================
-- Step 1: Download files from S3 (PowerShell job step)
-- ============================================================
-- Job Step Type: PowerShell
$bucket = "s3://bi-prod.tenproduct.com"
$projectKey = "BE_DJANGO_POSTGRES_CSV"
$localPath = "S:\TenDataWarehouseDependencies\$projectKey\ToBeProcessed"

# Download latest CSV files
aws s3 cp "$bucket/$projectKey" $localPath --exclude "Archive/*" --recursive

-- ============================================================
-- Step 2: Truncate all Django tables (T-SQL job step)
-- ============================================================
TRUNCATE TABLE django.articles;
TRUNCATE TABLE django.brands;
TRUNCATE TABLE django.dining_celebrity_chefs;
TRUNCATE TABLE django.dining_cuisine;
TRUNCATE TABLE django.dining_hot_table_bookings;
TRUNCATE TABLE django.dining_hot_tables;
TRUNCATE TABLE django.dining_restaurant_benefits;
TRUNCATE TABLE django.dining_restaurants;
TRUNCATE TABLE django.email_templates;
TRUNCATE TABLE django.entertainment_artists;
TRUNCATE TABLE django.entertainment_bookings;
TRUNCATE TABLE django.entertainment_delivery_methods;
TRUNCATE TABLE django.entertainment_event_tags;
TRUNCATE TABLE django.entertainment_events;
TRUNCATE TABLE django.entertainment_performances;
TRUNCATE TABLE django.entertainment_ticket_types;
TRUNCATE TABLE django.entertainment_venues;
TRUNCATE TABLE django.interest_id_entertainment_events;
TRUNCATE TABLE django.jobs;
TRUNCATE TABLE django.location_cities;
TRUNCATE TABLE django.location_countries;
TRUNCATE TABLE django.location_locationtags;
TRUNCATE TABLE django.member_benefit_memberbenefit_sites;
TRUNCATE TABLE django.member_benefit_memberbenefit_tags;
TRUNCATE TABLE django.member_benefits;
TRUNCATE TABLE django.member_details;
TRUNCATE TABLE django.member_events;
TRUNCATE TABLE django.member_events_bookings;
TRUNCATE TABLE django.member_events_dates;
TRUNCATE TABLE django.member_events_memberevent;
TRUNCATE TABLE django.member_events_memberevent_tags;
TRUNCATE TABLE django.member_profiles;
TRUNCATE TABLE django.partners;
TRUNCATE TABLE django.sites;
TRUNCATE TABLE django.tags;
TRUNCATE TABLE django.travel_airport_groups;
TRUNCATE TABLE django.travel_airports;
TRUNCATE TABLE django.travel_car_hire_depots;
TRUNCATE TABLE django.travel_hotels;

-- ============================================================
-- Step 3: Bulk insert each entity (T-SQL job step)
-- ============================================================
DECLARE @ProcessID VARCHAR(36) = CONVERT(CHAR(36), NEWID());
DECLARE @BasePath NVARCHAR(500) = 'S:\TenDataWarehouseDependencies\BE_DJANGO_POSTGRES_CSV\ToBeProcessed\';

-- Example: Load articles
BULK INSERT django.articles
FROM 'S:\TenDataWarehouseDependencies\BE_DJANGO_POSTGRES_CSV\ToBeProcessed\articles.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    TABLOCK
);

-- Update audit columns
UPDATE django.articles
SET inserted_on = GETDATE(), processid = @ProcessID
WHERE processid IS NULL;

-- Repeat for each entity...

-- ============================================================
-- Step 4: Archive files to S3 (PowerShell job step)
-- ============================================================
-- Job Step Type: PowerShell
aws s3 mv "$bucket/$projectKey" "$bucket/$projectKey/Archive" --recursive --exclude "Archive/*"
```

### Pros / Cons

| Pros | Cons |
|---|---|
| No SSIS dependency — simpler deployment | `BULK INSERT` less flexible than SSIS data flow for transformations |
| Easy to manage via SQL Agent GUI or scripts | `xp_cmdshell` security concerns for S3 interaction |
| Native SQL Server — no additional tooling | No built-in parallel load (would need multiple steps or `sp_executesql`) |
| Simple to monitor with SQL Agent job history | Harder to add derived columns inline (requires post-load UPDATE) |
| Works on any SQL Server edition with Agent | Format file management overhead for 38 entities |

---

## 12. Alternative Implementation — Python Script

### Complete Runnable Script

```python
#!/usr/bin/env python3
"""
Django Import ETL — Python replacement for SSIS Django_Import project.

Downloads pipe-delimited CSV files from S3, truncates destination tables,
and bulk-loads data into [django].* tables in TenDataWarehouse.

Requirements:
    pip install boto3 pyodbc pandas
"""

import os
import uuid
import logging
from datetime import datetime
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

import boto3
import pyodbc
import pandas as pd

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
S3_BUCKET = "bi-prod.tenproduct.com"
S3_PREFIX = "BE_DJANGO_POSTGRES_CSV"
LOCAL_STAGING = Path(r"S:\TenDataWarehouseDependencies\BE_DJANGO_POSTGRES_CSV\ToBeProcessed")

SQL_SERVER = "LDCSQLPD23"
SQL_DATABASE = "TenDataWarehouse"
SQL_SCHEMA = "django"

MAX_WORKERS = 8  # Parallel load threads

# All entities and their CSV source columns
ENTITIES = {
    "articles": ["id", "title", "slug", "tags", "created"],
    "brands": ["id", "name", "vendor_id"],
    "dining_celebrity_chefs": ["id", "name"],
    "dining_cuisine": ["id", "name"],
    "dining_hot_table_bookings": ["id", "member_id", "author_id", "hot_table_id", "status", "created"],
    "dining_hot_tables": ["id", "name", "id2", "number_of_seats", "available_at_datetime"],
    "dining_restaurant_benefits": ["id", "name", "benefit_code", "restaurant_id"],
    "dining_restaurants": [
        "id", "name", "latitude", "longitude", "city", "postcode", "country",
        "cuisine", "location_id", "price_indicator", "rating", "website", "vendor_id", "tags",
    ],
    "email_templates": ["name", "campaign_id", "name1", "sites", "subject"],
    "entertainment_artists": ["id", "name", "see_artist_id", "created_at"],
    "entertainment_bookings": [
        "id", "member_id", "author_id", "name", "status", "delivery_method_id",
        "performance_id", "payment_status", "external_id", "provider", "created",
    ],
    "entertainment_delivery_methods": ["id", "name", "price_currency", "provider"],
    "entertainment_event_tags": ["id", "event_id", "tag_id"],
    "entertainment_events": [
        "id", "name", "category", "number_of_performances", "popularity",
        "currency", "active", "created", "chosen_tags",
    ],
    "entertainment_performances": ["id", "event_id", "venue_id", "start_local_date_time", "ten_direct_vendor_id"],
    "entertainment_ticket_types": [
        "id", "performance_id", "see_offer_id", "see_price_id",
        "price", "price_currency", "face_price", "face_price_currency",
    ],
    "entertainment_venues": [
        "id", "name", "longitude", "latitude", "country", "postcode", "location_id", "see_venue_id",
    ],
    "interest_id_entertainment_events": ["primary_interest_id"],
    "jobs": ["gateway_id", "gateway_status", "jobid", "module", "productid"],
    "location_cities": [
        "id", "name", "geoname_id", "ivector_connect_geo_level_id",
        "ivector_connect_id", "ivector_connect_unique_code", "administrative_subdivision", "country",
    ],
    "location_countries": [
        "id", "name", "geoname_id", "ivector_connect_geo_level_id",
        "ivector_connect_id", "ivector_connect_unique_code", "alpha3_code", "iso_code",
    ],
    "location_locationtags": [
        "id", "name", "geoname_id", "ivector_connect_geo_level_id",
        "ivector_connect_id", "ivector_connect_unique_code",
    ],
    "member_benefit_memberbenefit_sites": ["id", "memberbenefit_id", "site_id"],
    "member_benefit_memberbenefit_tags": ["id", "memberbenefit_id", "tag_id"],
    "member_benefits": [
        "id", "name", "available_from", "available_until", "brand_id", "location_id",
        "status", "url_redemption", "online_redemption_code", "in_store_redemption",
        "has_redemption_phone_number", "phone_number", "rating", "alternate_rating",
        "chosen_tags", "sites", "ten_maid_offer_id",
    ],
    "member_details": ["id", "member_profile_id", "tag", "tag_id"],
    "member_events": [
        "id", "name", "latitude", "longitude", "city", "country", "postcode", "type",
        "adult_ticket_price", "adult_ticket_price_currency",
        "child_ticket_price", "child_ticket_price_currency",
        "chosen_tags", "sites", "supplier", "vendor_id",
    ],
    "member_events_bookings": [
        "id", "event_id", "member_id", "event_date", "booked_timestamp", "booking_status",
    ],
    "member_events_dates": ["id", "event_id", "local_datetime"],
    "member_events_memberevent": ["id", "name", "type", "supplier", "primary_interest_id"],
    "member_events_memberevent_tags": ["id", "memberevent_id", "tag_id"],
    "member_profiles": [
        "user_id", "created", "member_id", "ten_maid_corporate_scheme_id", "title",
        "email", "birth_date", "gender", "country_of_citizenship",
        "preferred_contact_method", "client_opt_in", "ten_opt_in",
        "terms_and_conditions_accepted_timestamp", "ten_maid_in_sync",
        "password_email_sent_datetime", "enable_calendar_invites",
        "enable_booking_reminders", "login_from_new_device_emails",
        "two_step_login", "weekly_newsletter", "member_events_invite",
        "dining_interest", "music_tickets", "theatre_interest", "art_exhibitions",
        "events_for_children", "other_attractions", "accessory_events_clothing",
        "travel_inspiration", "hotel_openings", "flight_sales", "viewed_tour",
        "account_activated", "password_hash",
    ],
    "partners": ["id", "name", "link", "chosen_tags", "sites"],
    "sites": ["site_id", "site_name"],
    "tags": [
        "id", "name", "tag_group", "articles_module", "travel_module",
        "dining_module", "entertainment_module", "member_benefits_module",
        "member_events_module", "interest_type", "is_interest", "created", "modified",
    ],
    "travel_airport_groups": ["id", "name", "ivector_connect_id", "airports"],
    "travel_airports": [
        "id", "name", "ivector_connect_id", "iata_code", "location_id", "latitude", "longitude",
    ],
    "travel_car_hire_depots": [
        "id", "latitude", "longitude", "ivector_connect_id", "name",
        "vendor_id", "location_id", "created", "deleted",
    ],
    "travel_hotels": [
        "id", "name", "ivector_connect_id", "latitude", "longitude",
        "star_rating", "location_id", "city", "country", "expedia_id", "benefit_collections",
    ],
}

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
log = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------
def get_connection() -> pyodbc.Connection:
    """Return a new ODBC connection to the data warehouse."""
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={SQL_SERVER};"
        f"DATABASE={SQL_DATABASE};"
        f"Trusted_Connection=yes;"
    )
    return pyodbc.connect(conn_str, autocommit=True)


def download_from_s3() -> None:
    """Download CSV files from S3 to the local staging folder."""
    log.info("Downloading files from s3://%s/%s …", S3_BUCKET, S3_PREFIX)
    LOCAL_STAGING.mkdir(parents=True, exist_ok=True)

    s3 = boto3.client("s3")
    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=S3_BUCKET, Prefix=S3_PREFIX):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            if "Archive" in key or not key.endswith(".csv"):
                continue
            filename = key.split("/")[-1]
            local_file = LOCAL_STAGING / filename
            log.info("  ↓ %s", filename)
            s3.download_file(S3_BUCKET, key, str(local_file))
    log.info("Download complete.")


def archive_to_s3() -> None:
    """Move processed S3 files to Archive subfolder."""
    log.info("Archiving files on S3 …")
    s3 = boto3.resource("s3")
    bucket = s3.Bucket(S3_BUCKET)
    for obj in bucket.objects.filter(Prefix=S3_PREFIX):
        if "Archive" in obj.key or not obj.key.endswith(".csv"):
            continue
        archive_key = obj.key.replace(S3_PREFIX, f"{S3_PREFIX}/Archive", 1)
        s3.Object(S3_BUCKET, archive_key).copy_from(
            CopySource={"Bucket": S3_BUCKET, "Key": obj.key}
        )
        obj.delete()
        log.info("  → Archived %s", obj.key)
    log.info("Archiving complete.")


def truncate_all_tables(conn: pyodbc.Connection) -> None:
    """Truncate all django.* target tables."""
    log.info("Truncating all django tables …")
    cursor = conn.cursor()
    for entity in ENTITIES:
        cursor.execute(f"TRUNCATE TABLE [{SQL_SCHEMA}].[{entity}]")
    log.info("All tables truncated.")


def load_entity(entity: str, columns: list[str]) -> dict:
    """Load a single entity CSV into its destination table."""
    csv_path = LOCAL_STAGING / f"{entity}.csv"
    result = {"entity": entity, "status": "skipped", "rows": 0}

    if not csv_path.exists():
        log.warning("File not found: %s — skipping", csv_path)
        return result

    process_id = str(uuid.uuid4())
    inserted_on = datetime.utcnow()

    try:
        # Read CSV — pipe-delimited, UTF-8, with header
        df = pd.read_csv(
            csv_path,
            sep="|",
            encoding="utf-8",
            dtype=str,           # Read everything as string; let SQL Server cast
            keep_default_na=False,
            na_values=[""],
        )

        # Strip whitespace from column names (some CSVs have trailing spaces)
        df.columns = [c.strip() for c in df.columns]

        # Add audit columns
        df["inserted_on"] = inserted_on
        df["processid"] = process_id

        # Insert into SQL Server
        conn = get_connection()
        cursor = conn.cursor()
        table = f"[{SQL_SCHEMA}].[{entity}]"

        # Build parameterised INSERT
        all_cols = [c.strip() for c in columns] + ["inserted_on", "processid"]
        col_list = ", ".join(f"[{c}]" for c in all_cols)
        placeholders = ", ".join("?" for _ in all_cols)
        insert_sql = f"INSERT INTO {table} ({col_list}) VALUES ({placeholders})"

        # Batch insert
        batch_size = 5000
        rows = df[all_cols].where(df[all_cols].notna(), None).values.tolist()
        for i in range(0, len(rows), batch_size):
            cursor.executemany(insert_sql, rows[i : i + batch_size])

        conn.close()
        result["status"] = "success"
        result["rows"] = len(rows)
        log.info("✓ %s — %d rows loaded", entity, len(rows))

    except Exception as exc:
        result["status"] = "error"
        result["error"] = str(exc)
        log.error("✗ %s — %s", entity, exc)

    return result


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    log.info("=" * 60)
    log.info("Django Import ETL — starting")
    log.info("=" * 60)

    # Step 1: Download from S3
    download_from_s3()

    # Step 2: Truncate all tables
    conn = get_connection()
    truncate_all_tables(conn)
    conn.close()

    # Step 3: Load all entities in parallel
    results = []
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as pool:
        futures = {
            pool.submit(load_entity, entity, cols): entity
            for entity, cols in ENTITIES.items()
        }
        for future in as_completed(futures):
            results.append(future.result())

    # Step 4: Archive files on S3
    archive_to_s3()

    # Summary
    log.info("=" * 60)
    success = sum(1 for r in results if r["status"] == "success")
    total_rows = sum(r["rows"] for r in results)
    log.info("Complete: %d/%d entities loaded, %d total rows", success, len(ENTITIES), total_rows)
    for r in sorted(results, key=lambda x: x["entity"]):
        log.info("  %-45s %s  (%d rows)", r["entity"], r["status"], r["rows"])
    log.info("=" * 60)


if __name__ == "__main__":
    main()
```

### Pros / Cons

| Pros | Cons |
|---|---|
| Platform-independent — runs on Linux, macOS, Windows | Requires Python runtime + package dependencies |
| Easy to add transformations with pandas | `pyodbc` bulk insert is slower than native SSIS OLE DB Destination |
| Native boto3 S3 integration (no AWS CLI install needed) | Thread-based parallelism limited by GIL (use `ProcessPoolExecutor` for CPU-bound work) |
| Simple to test with pytest / mock data | Connection string management outside SQL Server ecosystem |
| Version-controllable in Git | No built-in job scheduling (needs cron / Airflow / Step Functions) |
| Logging and error handling in one place | Memory pressure on large CSVs (mitigate with chunked reads) |
| Configuration-driven via `ENTITIES` dict | Need to handle data type casting carefully |

---

## 13. Alternative Implementation — AWS Glue

### Approach

Use an **AWS Glue Python Shell job** (or PySpark for very large datasets) that reads directly from S3, transforms in-memory, and writes to SQL Server via JDBC. This eliminates the on-premise staging folder entirely.

### AWS Glue Python Shell Job

```python
"""
AWS Glue Python Shell Job — Django Import ETL

Glue Job Parameters:
  --S3_BUCKET=bi-prod.tenproduct.com
  --S3_PREFIX=BE_DJANGO_POSTGRES_CSV
  --SQL_SERVER=LDCSQLPD23
  --SQL_DATABASE=TenDataWarehouse
  --GLUE_CONNECTION=TenDataWarehouse-JDBC
"""

import sys
import uuid
from datetime import datetime

import boto3
import pandas as pd
from awsglue.utils import getResolvedOptions

# Use pg8000 or pyodbc depending on Glue networking setup
# For SQL Server via JDBC, use jaydebeapi
import jaydebeapi

# ---------------------------------------------------------------------------
# Configuration from Glue job parameters
# ---------------------------------------------------------------------------
args = getResolvedOptions(sys.argv, [
    "S3_BUCKET", "S3_PREFIX", "SQL_SERVER", "SQL_DATABASE",
])

S3_BUCKET = args["S3_BUCKET"]
S3_PREFIX = args["S3_PREFIX"]
SQL_SERVER = args["SQL_SERVER"]
SQL_DATABASE = args["SQL_DATABASE"]
SQL_SCHEMA = "django"

# JDBC connection string (requires SQL Server JDBC driver in Glue job)
JDBC_URL = f"jdbc:sqlserver://{SQL_SERVER};databaseName={SQL_DATABASE};integratedSecurity=false"
JDBC_DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver"
JDBC_JAR = "/tmp/mssql-jdbc-12.4.2.jre11.jar"  # Uploaded as Glue job dependency

# Entity definitions (same as SSIS packages)
ENTITIES = {
    "articles": ["id", "title", "slug", "tags", "created"],
    "brands": ["id", "name", "vendor_id"],
    "dining_celebrity_chefs": ["id", "name"],
    "dining_cuisine": ["id", "name"],
    "dining_hot_table_bookings": ["id", "member_id", "author_id", "hot_table_id", "status", "created"],
    "dining_hot_tables": ["id", "name", "id2", "number_of_seats", "available_at_datetime"],
    "dining_restaurant_benefits": ["id", "name", "benefit_code", "restaurant_id"],
    "dining_restaurants": ["id", "name", "latitude", "longitude", "city", "postcode", "country", "cuisine", "location_id", "price_indicator", "rating", "website", "vendor_id", "tags"],
    "email_templates": ["name", "campaign_id", "name1", "sites", "subject"],
    "entertainment_artists": ["id", "name", "see_artist_id", "created_at"],
    "entertainment_bookings": ["id", "member_id", "author_id", "name", "status", "delivery_method_id", "performance_id", "payment_status", "external_id", "provider", "created"],
    "entertainment_delivery_methods": ["id", "name", "price_currency", "provider"],
    "entertainment_event_tags": ["id", "event_id", "tag_id"],
    "entertainment_events": ["id", "name", "category", "number_of_performances", "popularity", "currency", "active", "created", "chosen_tags"],
    "entertainment_performances": ["id", "event_id", "venue_id", "start_local_date_time", "ten_direct_vendor_id"],
    "entertainment_ticket_types": ["id", "performance_id", "see_offer_id", "see_price_id", "price", "price_currency", "face_price", "face_price_currency"],
    "entertainment_venues": ["id", "name", "longitude", "latitude", "country", "postcode", "location_id", "see_venue_id"],
    "interest_id_entertainment_events": ["primary_interest_id"],
    "jobs": ["gateway_id", "gateway_status", "jobid", "module", "productid"],
    "location_cities": ["id", "name", "geoname_id", "ivector_connect_geo_level_id", "ivector_connect_id", "ivector_connect_unique_code", "administrative_subdivision", "country"],
    "location_countries": ["id", "name", "geoname_id", "ivector_connect_geo_level_id", "ivector_connect_id", "ivector_connect_unique_code", "alpha3_code", "iso_code"],
    "location_locationtags": ["id", "name", "geoname_id", "ivector_connect_geo_level_id", "ivector_connect_id", "ivector_connect_unique_code"],
    "member_benefit_memberbenefit_sites": ["id", "memberbenefit_id", "site_id"],
    "member_benefit_memberbenefit_tags": ["id", "memberbenefit_id", "tag_id"],
    "member_benefits": ["id", "name", "available_from", "available_until", "brand_id", "location_id", "status", "url_redemption", "online_redemption_code", "in_store_redemption", "has_redemption_phone_number", "phone_number", "rating", "alternate_rating", "chosen_tags", "sites", "ten_maid_offer_id"],
    "member_details": ["id", "member_profile_id", "tag", "tag_id"],
    "member_events": ["id", "name", "latitude", "longitude", "city", "country", "postcode", "type", "adult_ticket_price", "adult_ticket_price_currency", "child_ticket_price", "child_ticket_price_currency", "chosen_tags", "sites", "supplier", "vendor_id"],
    "member_events_bookings": ["id", "event_id", "member_id", "event_date", "booked_timestamp", "booking_status"],
    "member_events_dates": ["id", "event_id", "local_datetime"],
    "member_events_memberevent": ["id", "name", "type", "supplier", "primary_interest_id"],
    "member_events_memberevent_tags": ["id", "memberevent_id", "tag_id"],
    "member_profiles": ["user_id", "created", "member_id", "ten_maid_corporate_scheme_id", "title", "email", "birth_date", "gender", "country_of_citizenship", "preferred_contact_method", "client_opt_in", "ten_opt_in", "terms_and_conditions_accepted_timestamp", "ten_maid_in_sync", "password_email_sent_datetime", "enable_calendar_invites", "enable_booking_reminders", "login_from_new_device_emails", "two_step_login", "weekly_newsletter", "member_events_invite", "dining_interest", "music_tickets", "theatre_interest", "art_exhibitions", "events_for_children", "other_attractions", "accessory_events_clothing", "travel_inspiration", "hotel_openings", "flight_sales", "viewed_tour", "account_activated", "password_hash"],
    "partners": ["id", "name", "link", "chosen_tags", "sites"],
    "sites": ["site_id", "site_name"],
    "tags": ["id", "name", "tag_group", "articles_module", "travel_module", "dining_module", "entertainment_module", "member_benefits_module", "member_events_module", "interest_type", "is_interest", "created", "modified"],
    "travel_airport_groups": ["id", "name", "ivector_connect_id", "airports"],
    "travel_airports": ["id", "name", "ivector_connect_id", "iata_code", "location_id", "latitude", "longitude"],
    "travel_car_hire_depots": ["id", "latitude", "longitude", "ivector_connect_id", "name", "vendor_id", "location_id", "created", "deleted"],
    "travel_hotels": ["id", "name", "ivector_connect_id", "latitude", "longitude", "star_rating", "location_id", "city", "country", "expedia_id", "benefit_collections"],
}


def get_jdbc_connection():
    """Open a JDBC connection to SQL Server."""
    return jaydebeapi.connect(
        JDBC_DRIVER,
        JDBC_URL,
        ["sql_user", "sql_password"],  # Use Glue Secrets Manager in production
        JDBC_JAR,
    )


def truncate_all(conn):
    """Truncate all target tables."""
    cursor = conn.cursor()
    for entity in ENTITIES:
        cursor.execute(f"TRUNCATE TABLE [{SQL_SCHEMA}].[{entity}]")
    cursor.close()
    print("All tables truncated.")


def load_entity(conn, entity, columns):
    """Read CSV from S3 and load into SQL Server."""
    s3_key = f"{S3_PREFIX}/{entity}.csv"
    s3_uri = f"s3://{S3_BUCKET}/{s3_key}"

    try:
        df = pd.read_csv(
            s3_uri,
            sep="|",
            encoding="utf-8",
            dtype=str,
            keep_default_na=False,
            na_values=[""],
            storage_options={"anon": False},  # Use IAM role
        )
        df.columns = [c.strip() for c in df.columns]

        process_id = str(uuid.uuid4())
        df["inserted_on"] = datetime.utcnow().isoformat()
        df["processid"] = process_id

        all_cols = [c.strip() for c in columns] + ["inserted_on", "processid"]
        table = f"[{SQL_SCHEMA}].[{entity}]"
        col_list = ", ".join(f"[{c}]" for c in all_cols)
        placeholders = ", ".join("?" for _ in all_cols)
        insert_sql = f"INSERT INTO {table} ({col_list}) VALUES ({placeholders})"

        cursor = conn.cursor()
        rows = df[all_cols].where(df[all_cols].notna(), None).values.tolist()
        for row in rows:
            cursor.execute(insert_sql, row)
        cursor.close()

        print(f"✓ {entity}: {len(rows)} rows loaded")

    except Exception as e:
        print(f"✗ {entity}: {e}")


def archive_s3_files():
    """Move processed files to Archive on S3."""
    s3 = boto3.resource("s3")
    bucket = s3.Bucket(S3_BUCKET)
    for obj in bucket.objects.filter(Prefix=S3_PREFIX):
        if "Archive" in obj.key or not obj.key.endswith(".csv"):
            continue
        archive_key = obj.key.replace(S3_PREFIX, f"{S3_PREFIX}/Archive", 1)
        s3.Object(S3_BUCKET, archive_key).copy_from(
            CopySource={"Bucket": S3_BUCKET, "Key": obj.key}
        )
        obj.delete()
    print("S3 archiving complete.")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
print("Django Import Glue Job — starting")
conn = get_jdbc_connection()

truncate_all(conn)
for entity, columns in ENTITIES.items():
    load_entity(conn, entity, columns)

conn.close()
archive_s3_files()
print("Django Import Glue Job — complete")
```

### AWS Glue PySpark Alternative (for large-scale entities)

```python
"""
AWS Glue PySpark Job — for entities with millions of rows.
Uses Spark JDBC writer for bulk parallel inserts.
"""
import sys
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import lit, current_timestamp
import uuid

args = getResolvedOptions(sys.argv, ["JOB_NAME", "SQL_SERVER", "SQL_DATABASE"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

JDBC_URL = f"jdbc:sqlserver://{args['SQL_SERVER']};databaseName={args['SQL_DATABASE']}"
JDBC_PROPS = {"user": "user", "password": "pass", "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"}

S3_PATH = "s3://bi-prod.tenproduct.com/BE_DJANGO_POSTGRES_CSV"

entities = ["articles", "brands", "dining_restaurants", "member_profiles"]  # etc.

for entity in entities:
    process_id = str(uuid.uuid4())
    s3_uri = f"{S3_PATH}/{entity}.csv"

    df = (
        spark.read
        .option("header", "true")
        .option("delimiter", "|")
        .option("encoding", "UTF-8")
        .csv(s3_uri)
    )

    df = (
        df.withColumn("inserted_on", current_timestamp())
          .withColumn("processid", lit(process_id))
    )

    # Truncate before write
    spark.read.jdbc(JDBC_URL, f"(SELECT 1 AS x) t", properties=JDBC_PROPS)  # test connection

    df.write.jdbc(
        url=JDBC_URL,
        table=f"django.{entity}",
        mode="overwrite",  # or "append" after manual truncate
        properties=JDBC_PROPS,
    )
    print(f"✓ {entity}: {df.count()} rows")

job.commit()
```

### Pros / Cons

| Pros | Cons |
|---|---|
| Serverless — no infrastructure to manage | Requires VPC/VPN connectivity to on-prem SQL Server |
| Native S3 access — no staging folder needed | JDBC to SQL Server adds latency vs. native OLE DB |
| Auto-scaling with PySpark for large datasets | Glue job cold start can take 1–2 minutes |
| Built-in scheduling via Glue Triggers/EventBridge | Cost per DPU-hour (Python Shell: ~$0.44/hr) |
| CloudWatch logging and metrics | Networking complexity (VPC endpoints, security groups) |
| IAM-based security — no stored credentials | More complex to debug than SSIS visual designer |
| Can process all 38 entities without local disk | SQL Server JDBC driver must be uploaded as job dependency |
| Integrates with AWS Step Functions for orchestration | Less mature than SSIS for SQL Server-centric ETL |

---

## Appendix: File Inventory

```
Django_Import/
├── @Project.manifest
├── [Content_Types].xml
├── DestinationServer_OLEDB.conmgr          # Project-level OLE DB connection
├── Project.params                          # Project parameter: ProjectKey
├── Control.dtsx                            # Main orchestrator (38 child packages)
├── Control_MemberProfile.dtsx              # Member profiles orchestrator (1 child)
├── _Load%20TEMPLATE.dtsx                   # Template pattern for all Load packages
├── load_data%20TO%20BE%20DELETED.dtsx      # Deprecated monolithic loader
├── Load%20articles.dtsx                    # 38 entity-specific Load packages
├── Load%20brands.dtsx                      #   ↓
├── Load%20dining_celebrity_chefs.dtsx
├── Load%20dining_cuisine.dtsx
├── Load%20dining_hot_table_bookings.dtsx
├── Load%20dining_hot_tables.dtsx
├── Load%20dining_restaurant_benefits.dtsx
├── Load%20dining_restaurants.dtsx
├── Load%20email_templates.dtsx
├── Load%20entertainment_artists.dtsx
├── Load%20entertainment_bookings.dtsx
├── Load%20entertainment_delivery_methods.dtsx
├── Load%20entertainment_event_tags.dtsx
├── Load%20entertainment_events.dtsx
├── Load%20entertainment_performances.dtsx
├── Load%20entertainment_ticket_types.dtsx
├── Load%20entertainment_venues.dtsx
├── Load%20interest_id_entertainment_events.dtsx
├── Load%20jobs.dtsx
├── Load%20location_cities.dtsx
├── Load%20location_countries.dtsx
├── Load%20location_locationtags.dtsx
├── Load%20member_benefit_memberbenefit_sites.dtsx
├── Load%20member_benefit_memberbenefit_tags.dtsx
├── Load%20member_benefits.dtsx
├── Load%20member_details.dtsx
├── Load%20member_events.dtsx
├── Load%20member_events_bookings.dtsx
├── Load%20member_events_dates.dtsx
├── Load%20member_events_memberevent.dtsx
├── Load%20member_events_memberevent_tags.dtsx
├── Load%20member_profiles.dtsx
├── Load%20partners.dtsx
├── Load%20sites.dtsx
├── Load%20tags.dtsx
├── Load%20travel_airport_groups.dtsx
├── Load%20travel_airports.dtsx
├── Load%20travel_car_hire_depots.dtsx
└── Load%20travel_hotels.dtsx
```
