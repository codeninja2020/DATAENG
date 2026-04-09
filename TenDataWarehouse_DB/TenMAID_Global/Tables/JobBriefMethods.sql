CREATE TABLE [TenMAID_Global].[JobBriefMethods] (
    [BriefMethodID]   INT          NOT NULL,
    [BriefMethodName] VARCHAR (50) NULL,
    [IsActive]        BIT          NULL,
    [OrderID]         INT          NULL,
    CONSTRAINT [PK_TenMAID_Global_JobBriefMethods] PRIMARY KEY CLUSTERED ([BriefMethodID] ASC)
);

