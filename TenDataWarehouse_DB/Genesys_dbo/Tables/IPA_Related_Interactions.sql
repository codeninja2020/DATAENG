CREATE TABLE [Genesys_dbo].[IPA_Related_Interactions] (
    [CallId]            CHAR (10)        NOT NULL,
    [CallIdKey]         CHAR (18)        NOT NULL,
    [DateRelated]       DATETIME2 (7)    NOT NULL,
    [DateRelatedOffset] INT              NOT NULL,
    [FlowExecID]        UNIQUEIDENTIFIER NOT NULL,
    [UserQueueID]       NVARCHAR (50)    NOT NULL,
    [Version]           INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_Related_Interactions] PRIMARY KEY CLUSTERED ([CallIdKey] ASC, [FlowExecID] ASC)
);

