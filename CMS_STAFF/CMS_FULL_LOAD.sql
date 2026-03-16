USE TEN_DATAWAREHOUSE;

    -- We store file config in a temp table and loop through each file
CREATE TABLE #CmsFiles (
    Id          INT IDENTITY(1,1),
    S3Arn       NVARCHAR(500),
    LocalPath   NVARCHAR(500),
    TableName   NVARCHAR(128),
    Processed   BIT DEFAULT 0
);
-- INSERT THE S3 FILE ARNS YOU WANT TO DOWNLOAD HERE
INSERT INTO #CmsFiles (S3Arn, LocalPath, TableName) VALUES
    (N'arn:aws:s3:::bi-staging.tenproduct.com/CMS/Dining.csv',          N'D:\S3\CMS\Dining.csv',          N'dbo.Dining'),
    (N'arn:aws:s3:::bi-staging.tenproduct.com/CMS/Hotels.csv',          N'D:\S3\CMS\Hotels.csv',          N'dbo.Hotels'),
    (N'arn:aws:s3:::bi-staging.tenproduct.com/CMS/Travel_Location.csv', N'D:\S3\CMS\Travel_Location.csv', N'dbo.Locations');

-- ── DOWNLOAD EACH FILE FROM S3 ──
SET @fileId = 1;
SET @maxFileId = (SELECT MAX(Id) FROM #CmsFiles);

WHILE @fileId <= @maxFileId
BEGIN
    SELECT @s3Arn = S3Arn, @localPath = LocalPath
    FROM #CmsFiles WHERE Id = @fileId;

    -- Start the download
    EXEC msdb.dbo.rds_download_from_s3
        @s3_arn_of_file  = @s3Arn,
        @rds_file_path   = @localPath,
        @overwrite_file  = 1;

    -- Get the task ID (most recent task for this file)
    SET @taskId = NULL;
    SELECT TOP 1 @taskId = task_id
    FROM msdb.dbo.rds_fn_task_status(NULL, NULL)
    WHERE task_type = 'DOWNLOAD_FROM_S3'
    ORDER BY task_id DESC;

    -- Poll until the download completes
    SET @status = N'IN_PROGRESS';
    WHILE @status IN (N'CREATED', N'IN_PROGRESS')
    BEGIN
        WAITFOR DELAY '00:00:05';   -- poll every 5 seconds

        SELECT @status = lifecycle
        FROM msdb.dbo.rds_fn_task_status(NULL, @taskId);
    END

    IF @status <> N'SUCCESS'
        RAISERROR('S3 download failed for %s — status: %s', 16, 1, @s3Arn, @status);

    SET @fileId = @fileId + 1;
END

PRINT 'CMS_S3_Download completed';

-- ── LOAD TO TABLES ──

DECLARE @ProcessId VARCHAR(36) = CONVERT(CHAR(36), NEWID());

-- ── Dining ──
TRUNCATE TABLE dbo.Dining;

-- Stage into temp table (all VARCHAR) then INSERT with type conversion + audit cols
CREATE TABLE #Dining_Raw (
    dining_id          VARCHAR(50),
    ivector_id         VARCHAR(50),
    ten_maid_vendor_id VARCHAR(50),
    dining_name        NVARCHAR(255),
    location_id        VARCHAR(50),
    latitude           VARCHAR(50),
    longitude          VARCHAR(50),
    held_table         VARCHAR(50)
);

BULK INSERT #Dining_Raw
FROM 'D:\S3\CMS\Dining.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 2,
    CODEPAGE        = '65001',
    TABLOCK
);

INSERT INTO dbo.Dining (dining_id, ivector_id, ten_maid_vendor_id, dining_name,
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
    @ProcessId,
    N'Dining.csv'
FROM #Dining_Raw;

DROP TABLE #Dining_Raw;

-- ── Hotels ──
TRUNCATE TABLE dbo.Hotels;

CREATE TABLE #Hotels_Raw (
    accommodation_id   VARCHAR(50),
    ivector_id         VARCHAR(50),
    accommodation_name NVARCHAR(255),
    rating             VARCHAR(50),
    latitude           VARCHAR(50),
    longitude          VARCHAR(50),
    location_id        VARCHAR(50),
    is_benefits_hotel  VARCHAR(50)
);

BULK INSERT #Hotels_Raw
FROM 'D:\S3\CMS\Hotels.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 2,
    CODEPAGE        = '65001',
    TABLOCK
);

INSERT INTO dbo.Hotels (accommodation_id, ivector_id, accommodation_name, rating,
                        latitude, longitude, location_id, is_benefits_hotel,
                        Inserted_On, ProcessId, FileName)
SELECT
    TRY_CAST(accommodation_id AS INT),
    TRY_CAST(ivector_id AS INT),
    accommodation_name,
    TRY_CAST(rating AS DECIMAL(5,2)),
    TRY_CAST(latitude AS FLOAT),
    TRY_CAST(longitude AS FLOAT),
    TRY_CAST(location_id AS INT),
    CASE WHEN is_benefits_hotel IN ('1', 'True', 'true', 'TRUE') THEN 1 ELSE 0 END,
    GETDATE(),
    @ProcessId,
    N'Hotels.csv'
FROM #Hotels_Raw;

DROP TABLE #Hotels_Raw;

-- ── Locations ──
TRUNCATE TABLE dbo.Locations;

CREATE TABLE #Locations_Raw (
    location_id   VARCHAR(50),
    geo_level     NVARCHAR(50),
    langcode      NVARCHAR(5),
    location_name NVARCHAR(500),
    latitude      VARCHAR(50),
    longitude     VARCHAR(50)
);

BULK INSERT #Locations_Raw
FROM 'D:\S3\CMS\Travel_Location.csv'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR   = '\n',
    FIRSTROW        = 2,
    CODEPAGE        = '65001',
    TABLOCK,
    KEEPNULLS
);

INSERT INTO dbo.Locations (location_id, geo_level, langcode, location_name,
                           latitude, longitude,
                           Inserted_On, ProcessId, FileName)
SELECT
    TRY_CAST(location_id AS INT),
    geo_level,
    langcode,
    location_name,
    TRY_CAST(latitude AS FLOAT),
    TRY_CAST(longitude AS FLOAT),
    GETDATE(),
    @ProcessId,
    N'Travel_Location.csv'
FROM #Locations_Raw;

DROP TABLE #Locations_Raw;

-- ── CLEAN UP LOCAL FILES ──
EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = N'D:\S3\CMS\Dining.csv';
EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = N'D:\S3\CMS\Hotels.csv';
EXEC msdb.dbo.rds_delete_from_filesystem @rds_file_path = N'D:\S3\CMS\Travel_Location.csv';

PRINT 'CMS_S3_Import completed — ProcessId: ' + @ProcessId;