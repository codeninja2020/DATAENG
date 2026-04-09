CREATE TABLE [TenMAID_Global].[FeedbackOutcomeLiesWith_Staging] (
    [FeedbackOutcomeLiesWith]   NVARCHAR (50) NULL,
    [FeedbackOutcomeLiesWithID] INT           NOT NULL,
    [SYS_CHANGE_OPERATION]      NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]        BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_FeedbackOutcomeLiesWith_Staging] PRIMARY KEY CLUSTERED ([FeedbackOutcomeLiesWithID] ASC)
);

