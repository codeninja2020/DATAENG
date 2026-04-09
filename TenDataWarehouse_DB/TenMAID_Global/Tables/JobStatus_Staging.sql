CREATE TABLE [TenMAID_Global].[JobStatus_Staging] (
    [Description]          NVARCHAR (200) NULL,
    [JobStatusID]          INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_JobStatus_Staging] PRIMARY KEY CLUSTERED ([JobStatusID] ASC)
);

