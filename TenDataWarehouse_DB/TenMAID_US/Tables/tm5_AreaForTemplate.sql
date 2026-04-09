CREATE TABLE [TenMAID_US].[tm5_AreaForTemplate] (
    [AreaId]           INT            NOT NULL,
    [AreasOnJobSheet]  NVARCHAR (500) NULL,
    [JobRequestTypeId] INT            NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_AreaForTemplate] PRIMARY KEY CLUSTERED ([AreaId] ASC)
);

