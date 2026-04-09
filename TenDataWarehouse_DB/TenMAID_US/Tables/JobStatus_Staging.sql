CREATE TABLE [TenMAID_US].[JobStatus_Staging] (
    [Description]          NVARCHAR (200) NULL,
    [JobStatusID]          INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_JobStatus_Staging] PRIMARY KEY CLUSTERED ([JobStatusID] ASC)
);

