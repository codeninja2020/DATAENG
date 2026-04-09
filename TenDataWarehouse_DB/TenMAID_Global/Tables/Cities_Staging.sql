CREATE TABLE [TenMAID_Global].[Cities_Staging] (
    [CityId]               INT            NOT NULL,
    [CountryID]            INT            NOT NULL,
    [RegionID]             INT            NULL,
    [City]                 NVARCHAR (255) NOT NULL,
    [Latitude]             FLOAT (53)     NULL,
    [Longitude]            FLOAT (53)     NULL,
    [TimeZone]             NVARCHAR (255) NULL,
    [DmaId]                INT            NULL,
    [Code]                 NVARCHAR (255) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TENMAID_Global_Cities_CityId_Staging] PRIMARY KEY CLUSTERED ([CityId] ASC)
);

