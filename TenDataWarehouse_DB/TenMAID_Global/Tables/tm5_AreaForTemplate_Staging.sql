CREATE TABLE [TenMAID_Global].[tm5_AreaForTemplate_Staging] (
    [AreaId]               INT            NOT NULL,
    [AreasOnJobSheet]      NVARCHAR (500) NULL,
    [JobRequestTypeId]     INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_AreaForTemplate_Staging] PRIMARY KEY CLUSTERED ([AreaId] ASC)
);

