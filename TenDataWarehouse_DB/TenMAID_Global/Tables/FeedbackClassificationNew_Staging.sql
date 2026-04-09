CREATE TABLE [TenMAID_Global].[FeedbackClassificationNew_Staging] (
    [FeedbackClassification]   NVARCHAR (150) NULL,
    [FeedbackClassificationID] INT            NOT NULL,
    [IsPositiveFeedback]       BIT            NULL,
    [SYS_CHANGE_OPERATION]     NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]       BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_FeedbackClassificationNew_Staging] PRIMARY KEY CLUSTERED ([FeedbackClassificationID] ASC)
);

