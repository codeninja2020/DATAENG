CREATE TABLE [TenMAID_Global].[Tbl_TimeZones_Staging] (
    [BaseUtcOffsetSec]           INT            NULL,
    [DaylightName]               NVARCHAR (100) NULL,
    [DisplayName]                NVARCHAR (100) NULL,
    [Identifier]                 NVARCHAR (100) NULL,
    [StandardName]               NVARCHAR (100) NULL,
    [SupportsDaylightSavingTime] BIT            NULL,
    [TimeZoneId]                 INT            NOT NULL,
    [SYS_CHANGE_OPERATION]       NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]         BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_TimeZones_Staging] PRIMARY KEY CLUSTERED ([TimeZoneId] ASC)
);

