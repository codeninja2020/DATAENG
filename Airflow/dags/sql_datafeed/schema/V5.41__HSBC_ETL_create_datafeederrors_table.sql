/* ============================================================================
   Versioned migration: V5.41__HSBC_ETL_create_datafeederrors_table.sql

   Purpose: Create HSBC_ETL.datafeederrors for HSBC validation rejects.

   Tables updated:
     - HSBC_ETL.datafeederrors
============================================================================ */

USE TENMAID_UAT;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'HSBC_ETL')
    EXEC (N'CREATE SCHEMA HSBC_ETL AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'HSBC_ETL.datafeederrors', N'U') IS NULL
BEGIN
    CREATE TABLE HSBC_ETL.datafeederrors
    (
        reject_id BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_HSBC_ETL_datafeederrors PRIMARY KEY,
        datafeed_id BIGINT NULL,
        processid VARCHAR(36) NOT NULL,
        validation_reason_codes NVARCHAR(MAX) NOT NULL,
        validation_errors NVARCHAR(MAX) NOT NULL,
        conflict_existing_references NVARCHAR(MAX) NULL,
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
        rejected_at DATETIME2(0) NOT NULL
            CONSTRAINT DF_HSBC_ETL_datafeederrors_rejected_at DEFAULT SYSDATETIME()
    );
END;
GO
