CREATE TABLE [TenMAID_US].[FeedbackClassificationNew_Staging] (
    [FeedbackClassification]   NVARCHAR (150) NULL,
    [FeedbackClassificationID] INT            NOT NULL,
    [IsPositiveFeedback]       BIT            NULL,
    [SYS_CHANGE_OPERATION]     NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]       BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackClassificationNew_Staging] PRIMARY KEY CLUSTERED ([FeedbackClassificationID] ASC)
);

