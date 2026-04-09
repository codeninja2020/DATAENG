CREATE TABLE [TenMAID_US].[tm5_SubRegion] (
    [CreatedBy]   INT           NULL,
    [CreatedDate] DATETIME      NULL,
    [Name]        VARCHAR (100) NULL,
    [RegionId]    INT           NULL,
    [SubRegionId] INT           NOT NULL,
    [UpdatedBy]   INT           NULL,
    [UpdatedDate] DATETIME      NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_SubRegion] PRIMARY KEY CLUSTERED ([SubRegionId] ASC)
);

