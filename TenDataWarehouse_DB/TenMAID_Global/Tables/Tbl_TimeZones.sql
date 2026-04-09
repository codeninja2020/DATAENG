CREATE TABLE [TenMAID_Global].[Tbl_TimeZones] (
    [BaseUtcOffsetSec]           INT            NULL,
    [DaylightName]               NVARCHAR (100) NULL,
    [DisplayName]                NVARCHAR (100) NULL,
    [Identifier]                 NVARCHAR (100) NULL,
    [StandardName]               NVARCHAR (100) NULL,
    [SupportsDaylightSavingTime] BIT            NULL,
    [TimeZoneId]                 INT            NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_TimeZones] PRIMARY KEY CLUSTERED ([TimeZoneId] ASC)
);

