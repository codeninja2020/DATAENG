CREATE TABLE [TenMAID_Global].[tm5_JobTitle_Staging] (
    [Description]          NVARCHAR (100) NULL,
    [JobTitleID]           INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_JobTitle_Staging] PRIMARY KEY CLUSTERED ([JobTitleID] ASC)
);

