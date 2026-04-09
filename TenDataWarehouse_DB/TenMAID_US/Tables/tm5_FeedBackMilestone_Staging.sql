CREATE TABLE [TenMAID_US].[tm5_FeedBackMilestone_Staging] (
    [FeedBackMilestoneID]  INT           NOT NULL,
    [FeedBackTypeID]       INT           NULL,
    [Name]                 NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_FeedBackMilestone_Staging] PRIMARY KEY CLUSTERED ([FeedBackMilestoneID] ASC)
);

