CREATE TABLE [TenMAID_US].[tm5_AdminJobType_Staging] (
    [AdminJobTypeID]       INT          NULL,
    [AdminJobTypeName]     VARCHAR (50) NULL,
    [ID]                   INT          NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_AdminJobType_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

