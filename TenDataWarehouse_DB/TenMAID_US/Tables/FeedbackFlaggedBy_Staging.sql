CREATE TABLE [TenMAID_US].[FeedbackFlaggedBy_Staging] (
    [FeedbackFlaggedBy]    NVARCHAR (50) NULL,
    [FeedbackFlaggedByID]  INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackFlaggedBy_Staging] PRIMARY KEY CLUSTERED ([FeedbackFlaggedByID] ASC)
);

