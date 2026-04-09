CREATE TABLE [Genesys_dbo].[IPA_States] (
    [EndDateTime]         DATETIME         NULL,
    [EndDateTimeOffset]   INT              NULL,
    [FlowExecID]          UNIQUEIDENTIFIER NOT NULL,
    [InitialActionExecID] UNIQUEIDENTIFIER NULL,
    [ParentActionExecID]  UNIQUEIDENTIFIER NULL,
    [StartDateTime]       DATETIME         NOT NULL,
    [StartDateTimeOffset] INT              NOT NULL,
    [StateExecID]         UNIQUEIDENTIFIER NOT NULL,
    [StateID]             UNIQUEIDENTIFIER NOT NULL,
    [Version]             INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_States] PRIMARY KEY CLUSTERED ([StateExecID] ASC)
);

