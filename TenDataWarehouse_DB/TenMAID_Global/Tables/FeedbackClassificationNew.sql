CREATE TABLE [TenMAID_Global].[FeedbackClassificationNew] (
    [FeedbackClassification]   NVARCHAR (150) NULL,
    [FeedbackClassificationID] INT            NOT NULL,
    [IsPositiveFeedback]       BIT            NULL,
    CONSTRAINT [PK_TenMAID_Global_FeedbackClassificationNew] PRIMARY KEY CLUSTERED ([FeedbackClassificationID] ASC)
);

