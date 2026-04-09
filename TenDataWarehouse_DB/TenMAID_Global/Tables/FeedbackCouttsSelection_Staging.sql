CREATE TABLE [TenMAID_Global].[FeedbackCouttsSelection_Staging] (
    [FeedbackCouttsSelection]   NVARCHAR (50) NULL,
    [FeedbackCouttsSelectionID] INT           NOT NULL,
    [SYS_CHANGE_OPERATION]      NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]        BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_FeedbackCouttsSelection_Staging] PRIMARY KEY CLUSTERED ([FeedbackCouttsSelectionID] ASC)
);

