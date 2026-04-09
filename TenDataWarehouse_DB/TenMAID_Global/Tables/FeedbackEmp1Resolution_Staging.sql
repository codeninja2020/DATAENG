CREATE TABLE [TenMAID_Global].[FeedbackEmp1Resolution_Staging] (
    [FeedbackEmp1ResolutionID] INT            NOT NULL,
    [Resolution]               NVARCHAR (250) NULL,
    [SYS_CHANGE_OPERATION]     NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]       BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_FeedbackEmp1Resolution_Staging] PRIMARY KEY CLUSTERED ([FeedbackEmp1ResolutionID] ASC)
);

