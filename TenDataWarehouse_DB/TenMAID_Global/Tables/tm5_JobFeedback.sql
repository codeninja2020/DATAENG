CREATE TABLE [TenMAID_Global].[tm5_JobFeedback] (
    [CreatedByEmployeeID]         INT             NULL,
    [DateCreated]                 DATETIME        NULL,
    [FeedBackClassificationID]    INT             NULL,
    [FeedBackMilestoneID]         INT             NULL,
    [InteractionClassificationID] INT             NULL,
    [IsResolved]                  BIT             NULL,
    [JobContact]                  INT             NULL,
    [JobFeedBackID]               INT             NOT NULL,
    [JobID]                       INT             NULL,
    [JobInteractionWith]          INT             NULL,
    [Notes]                       NVARCHAR (4000) NULL,
    [Story]                       NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_JobFeedback] PRIMARY KEY CLUSTERED ([JobFeedBackID] ASC)
);

