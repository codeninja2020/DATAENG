CREATE TABLE [cms].[Locations] (
    [location_id]   INT            NOT NULL,
    [geo_level]     NVARCHAR (50)  NULL,
    [langcode]      NVARCHAR (5)   NULL,
    [location_name] NVARCHAR (500) NULL,
    [latitude]      FLOAT (53)     NULL,
    [longitude]     FLOAT (53)     NULL,
    [Inserted_On]   DATETIME       NOT NULL,
    [ProcessId]     VARCHAR (36)   NULL,
    [FileName]      VARCHAR (255)  NULL
);

