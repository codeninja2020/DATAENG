CREATE TABLE [TenMAID_Global].[FeedbackMemberSatisfaction] (
    [FeedbackMemberSatisfaction]   NVARCHAR (100) NULL,
    [FeedbackMemberSatisfactionID] INT            NOT NULL,
    [OrderBy]                      INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_FeedbackMemberSatisfaction] PRIMARY KEY CLUSTERED ([FeedbackMemberSatisfactionID] ASC)
);

