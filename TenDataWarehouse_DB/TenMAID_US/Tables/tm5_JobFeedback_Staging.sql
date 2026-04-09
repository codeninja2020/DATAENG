CREATE TABLE [TenMAID_US].[tm5_JobFeedback_Staging] (
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
    [SYS_CHANGE_OPERATION]        NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]          BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_JobFeedback_Staging] PRIMARY KEY CLUSTERED ([JobFeedBackID] ASC)
);

