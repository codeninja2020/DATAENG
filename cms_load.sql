"""This script works and is the final
"""


SELECT DB_NAME() AS CurrentDatabase

SELECT name
FROM sys.schemas
ORDER BY name;

CREATE SCHEMA cms AUTHORIZATION dbo; -- create cms schema

--create tables
IF OBJECT_ID(N'cms.Dining', N'U') IS NULL
    CREATE TABLE cms.Dining (
        dining_id          INT PRIMARY KEY NOT NULL,
        ivector_id         INT NOT NULL,
        ten_maid_vendor_id INT NOT NULL,
        dining_name        NVARCHAR(255) NOT NULL,
        location_id        INT NOT NULL,
        latitude           FLOAT NOT NULL,
        longitude          FLOAT NOT NULL,
        held_table         BIT NOT NULL,
        Inserted_On        DATETIME NOT NULL,
        ProcessId          VARCHAR(36) NOT NULL,
        FileName           VARCHAR(255) NOT NULL
    );

IF OBJECT_ID(N'cms.Hotels', N'U') IS NULL
    CREATE TABLE cms.Hotels (
        accommodation_id    INT PRIMARY KEY NOT NULL,
        ivector_id          INT   NOT NULL,
        accommodation_name  NVARCHAR(255) NOT NULL,
        rating              NUMERIC(3,1)  NOT NULL,
        latitude            FLOAT  NOT NULL,
        longitude           FLOAT  NOT NULL,
        location_id         INT  NOT NULL,
        is_benefits_hotel   BIT  NOT NULL,
        Inserted_On         DATETIME  NOT NULL,
        ProcessId           VARCHAR(36)  NOT NULL,
        FileName            VARCHAR(255)  NOT NULL
    );

IF OBJECT_ID(N'cms.Locations', N'U') IS NULL
    CREATE TABLE cms.Locations (
        location_id    INT PRIMARY KEY  NOT NULL,
        geo_level      NVARCHAR(50)  NOT NULL,
        langcode       NVARCHAR(5)  NOT NULL,
        location_name  NVARCHAR(500)  NOT NULL,
        latitude       FLOAT  NOT NULL,
        longitude      FLOAT  NOT NULL,
        Inserted_On    DATETIME  NOT NULL,
        ProcessId      VARCHAR(36)  NOT NULL,
        FileName       VARCHAR(255)  NOT NULL
    );


SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'cms'
ORDER BY TABLE_NAME

-- check rds helper function
SELECT TOP 20 *
FROM msdb.dbo.rds_fn_task_status(NULL,NULL)
ORDER BY task_id DESC;

-- check if the procedure exists

SELECT OBJECT_ID('msdb.dbo.rds_fn_task_status') AS ProcExists
SELECT OBJECT_ID('msdb.dbo.rds_fn_task_status') AS FnExists

SELECT DB_NAME() AS CurrentDatabase

USE msdb
GO

EXEC sp_help 'msdb.dbo.rds_download_from_s3';

--dest 1 download

EXEC msdb.dbo.rds_download_from_s3
       @s3_arn_of_file = 'arn:aws:s3:::bi-staging.tenproduct.com/CMS/Dining.csv',
       @rds_file_path  = 'D:\S3\CMS\Dining.csv',
       @overwrite_file = 1 -- Yes to overwriting an existing file
    ;

-- check tasks ,check success
SELECT TOP 5 *
FROM msdb.dbo.rds_fn_task_status(NULL,29)
ORDER BY task_id DESC;

-- declare and run
DECLARE @status VARCHAR(50);
SET @status = 'IN_PROGRESS'

-- look to check only when in progress
WHILE @status IN ('CREATED','IN_PROGRESS')
BEGIN
    WAITFOR DELAY '00:00:05'
    SELECT @status = lifecycle
    FROM msdb.dbo.rds_fn_task_status(NULL, 28)
    PRINT 'Current status: ' + @status
END


SELECT TOP 1 task_id, task_type,lifecycle, task_info, created_at,last_updated
FROM msdb.dbo.rds_fn_task_status(NULL,29)
WHERE task_type = 'DOWNLOAD_FROM_S3'
ORDER BY task_id DESC

USE TEN_DATAWAREHOUSE

SELECT DB_NAME() AS CurrentDB;

-- ── Dining ──
--USE msdb
--GO
--SELECT DB_NAME() AS CurrentDB;


DECLARE @ProcessId VARCHAR(36)
SET @ProcessId = CONVERT(CHAR(36),NEWID());

TRUNCATE TABLE cms.Dining;

-- Stage into temp table (all VARCHAR) then INSERT with type conversion + audit cols
IF OBJECT_ID('tempdb..@Dining_Raw') IS NOT NULL
	DROP TABLE #Dining_Raw

CREATE TABLE #Dining_Raw (
    dining_id          VARCHAR(50),
    ivector_id         VARCHAR(50),
    ten_maid_vendor_id VARCHAR(50),
    dining_name        NVARCHAR(255),
    location_id        VARCHAR(50),
    latitude           VARCHAR(50),
    longitude          VARCHAR(50),
    held_table         VARCHAR(50),
    ProcessId	VARCHAR(50),
    FileName           VARCHAR(255)


);

-- VIEW FILE
SELECT TOP 20 *
FROM OPENROWSET(
	BULK 'D:\S3\CMS\Dining.csv',
	SINGLE_CLOB
) AS FileContents;

BULK INSERT #Dining_Raw
FROM 'D:\S3\CMS\Dining.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 2,
    CODEPAGE        = '65001',
    TABLOCK
);

-- 4. Check whether raw rows loaded
SELECT COUNT(*) AS RawRowCount FROM #Dining_Raw;
SELECT TOP 20 * FROM #Dining_Raw;


SELECT TOP 20 *
FROM msdb.dbo.rds_fn_task_status(NULL,29)
ORDER BY task_id DESC


INSERT INTO cms.Dining (dining_id, ivector_id, ten_maid_vendor_id, dining_name,
                        location_id, latitude, longitude, held_table,
                        Inserted_On, ProcessId, FileName)
SELECT
    TRY_CAST(dining_id AS INT),
    TRY_CAST(ivector_id AS INT),
    TRY_CAST(ten_maid_vendor_id AS INT),
    dining_name,
    TRY_CAST(location_id AS INT),
    TRY_CAST(latitude AS FLOAT),
    TRY_CAST(longitude AS FLOAT),
    CASE WHEN held_table IN ('1', 'True', 'true', 'TRUE') THEN 1 ELSE 0 END,
    GETDATE(),
    CONVERT(VARCHAR(36),NEWID()),
    N'Dining.csv'
FROM #Dining_Raw;

DROP TABLE #Dining_Raw;

SELECT COUNT(*)
FROM cms.Dining;
