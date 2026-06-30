/* ============================================================================
   Repeatable migration: R__HSBC_ETL_create_ucodes_table.sql

   Purpose: Create and seed HSBC_ETL.ucodes from ucodes.json.

   Tables updated:
     - HSBC_ETL.ucodes
============================================================================ */

USE TENMAID_UAT;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'HSBC_ETL')
    EXEC (N'CREATE SCHEMA HSBC_ETL AUTHORIZATION dbo;');
GO

IF OBJECT_ID(N'HSBC_ETL.ucodes', N'U') IS NULL
BEGIN
    CREATE TABLE HSBC_ETL.ucodes
    (
        id INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_HSBC_ETL_ucodes PRIMARY KEY,
        ucode NVARCHAR(20) NOT NULL,
        scheme_name NVARCHAR(50) NOT NULL,
        inserted_on DATETIME2(0) NOT NULL
            CONSTRAINT DF_HSBC_ETL_ucodes_inserted_on DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_HSBC_ETL_ucodes_ucode_scheme_name
            UNIQUE (ucode, scheme_name)
    );
END;
GO

MERGE HSBC_ETL.ucodes AS target
USING
(
    VALUES
        (N'UCOIV', N'PrivateBank'),
        (N'UCOIU', N'PrivateBank'),
        (N'UCOHW', N'PrivateBank'),
        (N'UCOIW', N'PrivateBank'),
        (N'UCOIQ', N'PrivateBank'),
        (N'UCOIR', N'PrivateBank'),
        (N'UCOIT', N'PrivateBank'),
        (N'UCOIS', N'PrivateBank'),
        (N'UFGCN', N'PrivateBank'),
        (N'UFGCR', N'PrivateBank'),
        (N'UCOHV', N'PrivateBank'),
        (N'UCOHX', N'PrivateBank'),
        (N'UCOHZ', N'PrivateBank'),
        (N'UCOHY', N'PrivateBank'),
        (N'UCOIA', N'PrivateBank'),
        (N'UCOIB', N'PrivateBank'),
        (N'UCOIC', N'PrivateBank'),
        (N'UCOID', N'PrivateBank'),
        (N'UCOIE', N'PrivateBank'),
        (N'UCOIX', N'PrivateBank'),
        (N'UCOIY', N'PrivateBank'),
        (N'UCNBW', N'Premier'),
        (N'UCNBX', N'Premier'),
        (N'UCNJF', N'Premier'),
        (N'UCOBU', N'Premier'),
        (N'UADFA', N'Premier'),
        (N'UADFC', N'Premier'),
        (N'UCHPT', N'Premier'),
        (N'UCHPU', N'Premier'),
        (N'UCNHR', N'Premier'),
        (N'UCNJH', N'Premier'),
        (N'UEDAA', N'Premier'),
        (N'UEDAB', N'Premier'),
        (N'UCHYM', N'Premier'),
        (N'UCNCA', N'Premier'),
        (N'UCNCB', N'Premier'),
        (N'UADFI', N'Premier'),
        (N'UADFK', N'Premier'),
        (N'UCHPX', N'Premier'),
        (N'UCHPY', N'Premier'),
        (N'UCNHT', N'Premier'),
        (N'UADFJ', N'Premier'),
        (N'UADFL', N'Premier'),
        (N'UEDAE', N'Premier'),
        (N'UEDAF', N'Premier'),
        (N'UCIBB', N'Premier'),
        (N'UCIBC', N'Premier'),
        (N'UCNPW', N'Premier'),
        (N'UCNPX', N'Premier'),
        (N'UCIAX', N'Premier'),
        (N'UCIAY', N'Premier'),
        (N'UCNPS', N'Premier'),
        (N'UCNPT', N'Premier'),
        (N'UCNIU', N'Premier')
) AS source (ucode, scheme_name)
ON target.ucode = source.ucode
   AND target.scheme_name = source.scheme_name
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ucode, scheme_name)
    VALUES (source.ucode, source.scheme_name)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;
GO
