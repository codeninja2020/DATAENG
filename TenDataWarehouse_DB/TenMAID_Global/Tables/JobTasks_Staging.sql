CREATE TABLE [TenMAID_Global].[JobTasks_Staging] (
    [Complete]             BIT            NULL,
    [CompletedByEmpID]     INT            NULL,
    [CreatedByEmpID]       INT            NULL,
    [DateCompleted]        DATETIME       NULL,
    [DateDue]              DATETIME       NULL,
    [EventID]              INT            NULL,
    [IsManualTask]         BIT            NULL,
    [JobID]                INT            NULL,
    [Subject]              NVARCHAR (120) NULL,
    [TaskID]               INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_JobTasks_Staging] PRIMARY KEY CLUSTERED ([TaskID] ASC)
);

