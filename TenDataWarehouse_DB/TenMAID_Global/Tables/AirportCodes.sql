CREATE TABLE [TenMAID_Global].[AirportCodes] (
    [CityName]      NVARCHAR (255) NULL,
    [AirportCode]   CHAR (3)       NOT NULL,
    [CountryName]   NVARCHAR (255) NULL,
    [CountryCode]   CHAR (3)       NULL,
    [WorldAreaCode] INT            NULL,
    [Airport name]  NVARCHAR (255) NULL,
    CONSTRAINT [PK_TENMAID_Global_AirportCodes] PRIMARY KEY CLUSTERED ([AirportCode] ASC)
);

