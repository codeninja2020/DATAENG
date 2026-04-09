CREATE TABLE [TenMAID_Global].[tm5_AreaForTemplate] (
    [AreaId]           INT            NOT NULL,
    [AreasOnJobSheet]  NVARCHAR (500) NULL,
    [JobRequestTypeId] INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_AreaForTemplate] PRIMARY KEY CLUSTERED ([AreaId] ASC)
);

