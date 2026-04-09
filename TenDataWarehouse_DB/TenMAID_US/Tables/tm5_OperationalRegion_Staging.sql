CREATE TABLE [TenMAID_US].[tm5_OperationalRegion_Staging] (
    [RegionID]             INT           NOT NULL,
    [RegionName]           VARCHAR (200) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_OperationalRegion_Staging] PRIMARY KEY CLUSTERED ([RegionID] ASC)
);

