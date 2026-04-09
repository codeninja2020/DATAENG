CREATE TABLE [TenMAID_Global].[FeedbackType_Staging] (
    [FeedbackType]         NVARCHAR (50) NULL,
    [FeedbackTypeID]       INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_FeedbackType_Staging] PRIMARY KEY CLUSTERED ([FeedbackTypeID] ASC)
);

