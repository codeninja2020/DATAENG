CREATE TABLE [Genesys_dbo].[IPA_Tasks] (
    [DueDateTime]         DATETIME         NULL,
    [DueDateTimeOffSet]   INT              NULL,
    [EndDateTime]         DATETIME         NULL,
    [EndDateTimeOffset]   INT              NULL,
    [FlowExecID]          UNIQUEIDENTIFIER NOT NULL,
    [InitialActionExecID] UNIQUEIDENTIFIER NULL,
    [ParentActionExecID]  UNIQUEIDENTIFIER NOT NULL,
    [ParentStateExecID]   UNIQUEIDENTIFIER NULL,
    [ParentTaskExecID]    UNIQUEIDENTIFIER NULL,
    [StartDateTime]       DATETIME         NOT NULL,
    [StartDateTimeOffset] INT              NOT NULL,
    [TaskExecID]          UNIQUEIDENTIFIER NOT NULL,
    [TaskID]              UNIQUEIDENTIFIER NOT NULL,
    [TaskOutput]          NVARCHAR (128)   NULL,
    [TaskTypeID]          INT              NOT NULL,
    [Version]             INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_Tasks] PRIMARY KEY CLUSTERED ([TaskExecID] ASC)
);

