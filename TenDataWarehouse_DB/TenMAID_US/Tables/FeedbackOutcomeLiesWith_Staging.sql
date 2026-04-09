CREATE TABLE [TenMAID_US].[FeedbackOutcomeLiesWith_Staging] (
    [FeedbackOutcomeLiesWith]   NVARCHAR (50) NULL,
    [FeedbackOutcomeLiesWithID] INT           NOT NULL,
    [SYS_CHANGE_OPERATION]      NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]        BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackOutcomeLiesWith_Staging] PRIMARY KEY CLUSTERED ([FeedbackOutcomeLiesWithID] ASC)
);

