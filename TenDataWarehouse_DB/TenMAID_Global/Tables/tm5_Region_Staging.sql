CREATE TABLE [TenMAID_Global].[tm5_Region_Staging] (
    [Description]          NVARCHAR (100) NULL,
    [RegionID]             INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_Region_Staging] PRIMARY KEY CLUSTERED ([RegionID] ASC)
);

