/* ============================================================================
   Versioned migration: V5.40__HSBC_ETL_create_s3_download_tracking_table.sql

   Purpose: Create HSBC_ETL.S3_Download_Tracking for HSBC S3 download audit.

   Tables updated:
     - HSBC_ETL.S3_Download_Tracking
============================================================================ */

USE TENMAID_UAT;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'HSBC_ETL')
    EXEC (N'CREATE SCHEMA HSBC_ETL AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'HSBC_ETL.S3_Download_Tracking', N'U') IS NULL
BEGIN
    CREATE TABLE HSBC_ETL.S3_Download_Tracking
    (
        id INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_HSBC_ETL_S3_Download_Tracking PRIMARY KEY,
        run_id UNIQUEIDENTIFIER NOT NULL,
        file_name NVARCHAR(200) NOT NULL,
        target_schema SYSNAME NOT NULL,
        target_table SYSNAME NOT NULL,
        s3_path NVARCHAR(500) NOT NULL,
        local_path NVARCHAR(500) NOT NULL,
        task_id INT NULL,
        lifecycle NVARCHAR(100) NOT NULL,
        task_info NVARCHAR(MAX) NULL,
        created_at DATETIME2(0) NOT NULL
            CONSTRAINT DF_HSBC_ETL_S3_Download_Tracking_created_at DEFAULT SYSDATETIME(),
        completed_at DATETIME2(0) NULL
    );
END;
GO
