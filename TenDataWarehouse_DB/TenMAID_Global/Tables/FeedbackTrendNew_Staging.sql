CREATE TABLE [TenMAID_Global].[FeedbackTrendNew_Staging] (
    [ClassificationID]     INT            NULL,
    [Description]          NVARCHAR (200) NULL,
    [ID]                   INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_FeedbackTrendNew_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

