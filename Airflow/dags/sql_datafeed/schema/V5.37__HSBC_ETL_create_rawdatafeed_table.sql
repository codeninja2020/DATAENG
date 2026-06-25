/* ============================================================================
   Repeatable migration: R__HSBC_ETL_create_rawdatafeed_table.sql

   Purpose: Create a raw table to store members_datafeed_example.csv in the DB
            before loading/transformation into TENMAID_UAT.members.

   Tables updated:
     - HSBC_ETL.rawdatafeed
============================================================================ */

USE TENMAID_UAT;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'HSBC_ETL')
    EXEC (N'CREATE SCHEMA HSBC_ETL AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'HSBC_ETL.rawdatafeed', N'U') IS NULL
BEGIN
    CREATE TABLE HSBC_ETL.rawdatafeed
    (
        id BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_HSBC_ETL_rawdatafeed PRIMARY KEY,
        CIN NVARCHAR(100) NULL,
        segment NVARCHAR(100) NULL,
        scheme_name NVARCHAR(200) NULL,
        membership_status NVARCHAR(50) NULL,
        title_code NVARCHAR(50) NULL,
        first_name NVARCHAR(200) NULL,
        last_name NVARCHAR(200) NULL,
        gender_code NVARCHAR(50) NULL,
        language_code NVARCHAR(50) NULL,
        date_of_birth NVARCHAR(50) NULL,
        address_line_1 NVARCHAR(500) NULL,
        address_line_2 NVARCHAR(500) NULL,
        town_city NVARCHAR(200) NULL,
        state_region NVARCHAR(200) NULL,
        post_code NVARCHAR(50) NULL,
        country_code NVARCHAR(50) NULL,
        email_address NVARCHAR(320) NULL,
        main_phone NVARCHAR(100) NULL,
        business_phone NVARCHAR(100) NULL,
        home_phone NVARCHAR(100) NULL,
        inserted_on DATETIME2(0) NOT NULL
            CONSTRAINT DF_HSBC_ETL_rawdatafeed_inserted_on DEFAULT SYSDATETIME(),
        load_ts DATETIME2(0) NOT NULL
            CONSTRAINT DF_HSBC_ETL_rawdatafeed_load_ts DEFAULT SYSDATETIME(),
        source NVARCHAR(500) NULL,
        dq_passed BIT NOT NULL
            CONSTRAINT DF_HSBC_ETL_rawdatafeed_dq_passed DEFAULT 0,
        processid VARCHAR(36) NULL
    );
END;
GO
