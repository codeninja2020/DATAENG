CREATE TABLE [TenMAID_US].[JobBriefMethods] (
    [BriefMethodID]   INT          NOT NULL,
    [BriefMethodName] VARCHAR (50) NULL,
    [IsActive]        BIT          NULL,
    [OrderID]         INT          NULL,
    CONSTRAINT [PK_TenMAID_US_JobBriefMethods] PRIMARY KEY CLUSTERED ([BriefMethodID] ASC)
);

