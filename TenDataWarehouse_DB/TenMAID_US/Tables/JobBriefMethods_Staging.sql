CREATE TABLE [TenMAID_US].[JobBriefMethods_Staging] (
    [BriefMethodID]        INT          NOT NULL,
    [BriefMethodName]      VARCHAR (50) NULL,
    [IsActive]             BIT          NULL,
    [OrderID]              INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_JobBriefMethods_Staging] PRIMARY KEY CLUSTERED ([BriefMethodID] ASC)
);

