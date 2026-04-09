CREATE TABLE [TenMAID_US].[tm5_SubRegion_Staging] (
    [CreatedBy]            INT           NULL,
    [CreatedDate]          DATETIME      NULL,
    [Name]                 VARCHAR (100) NULL,
    [RegionId]             INT           NULL,
    [SubRegionId]          INT           NOT NULL,
    [UpdatedBy]            INT           NULL,
    [UpdatedDate]          DATETIME      NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_SubRegion_Staging] PRIMARY KEY CLUSTERED ([SubRegionId] ASC)
);

