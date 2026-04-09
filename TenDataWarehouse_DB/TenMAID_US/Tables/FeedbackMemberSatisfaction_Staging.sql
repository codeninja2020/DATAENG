CREATE TABLE [TenMAID_US].[FeedbackMemberSatisfaction_Staging] (
    [FeedbackMemberSatisfaction]   NVARCHAR (100) NULL,
    [FeedbackMemberSatisfactionID] INT            NOT NULL,
    [OrderBy]                      INT            NULL,
    [SYS_CHANGE_OPERATION]         NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]           BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackMemberSatisfaction_Staging] PRIMARY KEY CLUSTERED ([FeedbackMemberSatisfactionID] ASC)
);

