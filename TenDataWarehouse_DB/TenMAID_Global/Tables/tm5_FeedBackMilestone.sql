CREATE TABLE [TenMAID_Global].[tm5_FeedBackMilestone] (
    [FeedBackMilestoneID] INT           NOT NULL,
    [FeedBackTypeID]      INT           NULL,
    [Name]                NVARCHAR (50) NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_FeedBackMilestone] PRIMARY KEY CLUSTERED ([FeedBackMilestoneID] ASC)
);

