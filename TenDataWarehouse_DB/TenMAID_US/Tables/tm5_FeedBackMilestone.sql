CREATE TABLE [TenMAID_US].[tm5_FeedBackMilestone] (
    [FeedBackMilestoneID] INT           NOT NULL,
    [FeedBackTypeID]      INT           NULL,
    [Name]                NVARCHAR (50) NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_FeedBackMilestone] PRIMARY KEY CLUSTERED ([FeedBackMilestoneID] ASC)
);

