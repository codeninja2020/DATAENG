CREATE TABLE [Genesys_dbo].[flowexec_Completion] (
    [ChildExecID]  UNIQUEIDENTIFIER NOT NULL,
    [CompleteCode] INT              NULL,
    [CompleteTime] BIGINT           NULL,
    [CompleteVars] NVARCHAR (MAX)   NULL,
    [CompletionID] UNIQUEIDENTIFIER NOT NULL,
    [ParentExecID] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_flowexec_Completion] PRIMARY KEY CLUSTERED ([CompletionID] ASC)
);

