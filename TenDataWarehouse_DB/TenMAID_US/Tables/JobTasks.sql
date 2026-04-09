CREATE TABLE [TenMAID_US].[JobTasks] (
    [Complete]         BIT            NOT NULL,
    [CompletedByEmpID] INT            NULL,
    [CreatedByEmpID]   INT            NOT NULL,
    [DateCompleted]    DATETIME       NULL,
    [DateDue]          DATETIME       NOT NULL,
    [EventID]          INT            NULL,
    [IsManualTask]     BIT            NULL,
    [JobID]            INT            NOT NULL,
    [Subject]          NVARCHAR (120) NOT NULL,
    [TaskID]           INT            NOT NULL,
    CONSTRAINT [PK_TenMAID_US_JobTasks] PRIMARY KEY CLUSTERED ([TaskID] ASC)
);

