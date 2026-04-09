CREATE TABLE [TenMAID_US].[FeedbackEmp2Resolution_Staging] (
    [FeedbackEmp2ResolutionID] INT            NOT NULL,
    [Resolution]               NVARCHAR (250) NULL,
    [SYS_CHANGE_OPERATION]     NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]       BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_FeedbackEmp2Resolution_Staging] PRIMARY KEY CLUSTERED ([FeedbackEmp2ResolutionID] ASC)
);

