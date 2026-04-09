CREATE TABLE [TenMAID_US].[AirportCodes_Staging] (
    [CityName]             NVARCHAR (255) NULL,
    [AirportCode]          CHAR (3)       NOT NULL,
    [CountryName]          NVARCHAR (255) NULL,
    [CountryCode]          CHAR (3)       NULL,
    [WorldAreaCode]        INT            NULL,
    [Airport name]         NVARCHAR (255) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TENMAID_US_AirportCodes_Staging] PRIMARY KEY CLUSTERED ([AirportCode] ASC)
);

