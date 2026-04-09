CREATE TABLE [Genesys_dbo].[IPA_Work_Items] (
    [ActionID]            UNIQUEIDENTIFIER NOT NULL,
    [ActionType]          NVARCHAR (128)   NOT NULL,
    [Category]            NVARCHAR (1024)  NOT NULL,
    [Description]         NVARCHAR (1024)  NOT NULL,
    [DueDateUTC]          DATETIME2 (7)    NULL,
    [EndDateTime]         DATETIME2 (7)    NULL,
    [EndDateTimeOffset]   INT              NULL,
    [FlowExecID]          UNIQUEIDENTIFIER NOT NULL,
    [InitialActionExecID] UNIQUEIDENTIFIER NULL,
    [ParentActionExecID]  UNIQUEIDENTIFIER NULL,
    [StartDateTime]       DATETIME2 (7)    NOT NULL,
    [StartDateTimeOffset] INT              NOT NULL,
    [StateExecID]         UNIQUEIDENTIFIER NULL,
    [TaskExecID]          UNIQUEIDENTIFIER NULL,
    [Version]             INT              NOT NULL,
    [WorkItemExecID]      UNIQUEIDENTIFIER NOT NULL,
    [WorkItemID]          UNIQUEIDENTIFIER NOT NULL,
    [WorkItemOutputID]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_Work_Items] PRIMARY KEY CLUSTERED ([WorkItemExecID] ASC)
);

