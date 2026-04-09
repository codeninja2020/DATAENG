CREATE TABLE [TenMAID_US].[FeedbackCouttsSelection_Staging] (
    [FeedbackCouttsSelection]   NVARCHAR (50) NULL,
    [FeedbackCouttsSelectionID] INT           NOT NULL,
    [SYS_CHANGE_OPERATION]      NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]        BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackCouttsSelection_Staging] PRIMARY KEY CLUSTERED ([FeedbackCouttsSelectionID] ASC)
);

