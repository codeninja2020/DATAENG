CREATE TABLE [TenMAID_US].[FeedbackClassificationNew] (
    [FeedbackClassification]   NVARCHAR (150) NULL,
    [FeedbackClassificationID] INT            NOT NULL,
    [IsPositiveFeedback]       BIT            NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackClassificationNew] PRIMARY KEY CLUSTERED ([FeedbackClassificationID] ASC)
);

