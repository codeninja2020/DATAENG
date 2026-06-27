/*
Purpose: Diagnose and remediate the legacy error
  "Loader No SSIS_tableConfig setup db"
for dbo.TenGroupFileLoader.

Run this in the target SQL Server instance.
*/

USE TenDataWarehouse;
GO

/* 1) Confirm procedure exists */
SELECT OBJECT_ID('dbo.TenGroupFileLoader', 'P') AS TenGroupFileLoader_object_id;
GO

/* 2) Inspect procedure text for SSIS_tableConfig dependency */
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.TenGroupFileLoader', 'P')) AS TenGroupFileLoader_definition;
GO

/* 3) Check whether legacy config table exists */
SELECT OBJECT_ID('dbo.SSIS_tableConfig', 'U') AS SSIS_tableConfig_object_id;
GO

/* 4) If table missing, create a minimal compatible config table
      (adjust schema if your procedure expects additional columns). */
IF OBJECT_ID('dbo.SSIS_tableConfig', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SSIS_tableConfig
    (
        LoaderNo        INT            NOT NULL,
        SourceFile      NVARCHAR(260)  NULL,
        SchemaName      SYSNAME        NULL,
        TableName       SYSNAME        NULL,
        ServerId        INT            NULL,
        TargetSchema    SYSNAME        NULL,
        TargetTable     SYSNAME        NULL,
        IsActive        BIT            NOT NULL DEFAULT (1),
        TruncateBeforeLoad BIT         NOT NULL DEFAULT (1),
        FieldTerm       NVARCHAR(10)   NOT NULL DEFAULT ('|'),
        RowTerm         NVARCHAR(10)   NOT NULL DEFAULT ('0x0a'),
        CONSTRAINT PK_SSIS_tableConfig PRIMARY KEY (LoaderNo)
    );
END;
GO


/* 4b) Ensure required legacy columns exist even when table already exists */
IF COL_LENGTH('dbo.SSIS_tableConfig', 'SchemaName') IS NULL
    ALTER TABLE dbo.SSIS_tableConfig ADD SchemaName SYSNAME NULL;
IF COL_LENGTH('dbo.SSIS_tableConfig', 'TableName') IS NULL
    ALTER TABLE dbo.SSIS_tableConfig ADD TableName SYSNAME NULL;
IF COL_LENGTH('dbo.SSIS_tableConfig', 'ServerId') IS NULL
    ALTER TABLE dbo.SSIS_tableConfig ADD ServerId INT NULL;
GO

/* 4c) Ensure legacy server config exists (needed by some TenGroupFileLoader variants) */
IF OBJECT_ID('dbo.SSIS_ServerConfig', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SSIS_ServerConfig
    (
        ServerId        INT            NOT NULL,
        ServerName      NVARCHAR(128)  NULL,
        DatabaseName    NVARCHAR(128)  NULL,
        IsActive        BIT            NOT NULL DEFAULT (1),
        CONSTRAINT PK_SSIS_ServerConfig PRIMARY KEY (ServerId)
    );
END;
GO

/* 4d) Seed default server config row for ServerId = 1 if missing */
IF NOT EXISTS (SELECT 1 FROM dbo.SSIS_ServerConfig WHERE ServerId = 1)
BEGIN
    INSERT INTO dbo.SSIS_ServerConfig (ServerId, ServerName, DatabaseName, IsActive)
    VALUES (1, @@SERVERNAME, DB_NAME(), 1);
END;
GO

/* 4e) Show SSIS_ServerConfig contents */
SELECT ServerId, ServerName, DatabaseName, IsActive
FROM dbo.SSIS_ServerConfig
ORDER BY ServerId;
GO

/* 5) Show expected columns vs actual columns to quickly detect mismatch */
SELECT c.name, t.name AS type_name, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.SSIS_tableConfig', 'U')
ORDER BY c.column_id;
GO

/* 6) Optional: seed a sample row for LoaderNo = 1 if none exists */
IF NOT EXISTS (SELECT 1 FROM dbo.SSIS_tableConfig WHERE LoaderNo = 1)
BEGIN
    INSERT INTO dbo.SSIS_tableConfig (LoaderNo, SourceFile, SchemaName, TableName, ServerId, TargetSchema, TargetTable)
    VALUES (1, N'example.csv', N'django', N'articles', 1, N'django', N'articles');
END;
GO

/* 7) Re-run loader and capture exact SQL error */
BEGIN TRY
    EXEC dbo.TenGroupFileLoader @LoaderNo = 1;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS error_number,
        ERROR_SEVERITY() AS error_severity,
        ERROR_STATE() AS error_state,
        ERROR_PROCEDURE() AS error_procedure,
        ERROR_LINE() AS error_line,
        ERROR_MESSAGE() AS error_message;
END CATCH;
GO
