CREATE TABLE [TenMAID_US].[FeedbackMemberSatisfaction] (
    [FeedbackMemberSatisfaction]   NVARCHAR (100) NULL,
    [FeedbackMemberSatisfactionID] INT            NOT NULL,
    [OrderBy]                      INT            NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackMemberSatisfaction] PRIMARY KEY CLUSTERED ([FeedbackMemberSatisfactionID] ASC)
);

