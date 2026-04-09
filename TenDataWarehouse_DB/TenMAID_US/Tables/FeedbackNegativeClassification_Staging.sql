CREATE TABLE [TenMAID_US].[FeedbackNegativeClassification_Staging] (
    [FeedbackNegativeClass]   INT          NULL,
    [FeedbackNegativeClassID] INT          NOT NULL,
    [SYS_CHANGE_OPERATION]    NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]      BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackNegativeClassification_Staging] PRIMARY KEY CLUSTERED ([FeedbackNegativeClassID] ASC)
);

