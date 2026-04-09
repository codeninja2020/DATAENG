CREATE TABLE [Genesys_dbo].[IPA_Flow_Notes] (
    [FlowExecID]           UNIQUEIDENTIFIER NOT NULL,
    [ICUserID]             NVARCHAR (50)    NOT NULL,
    [LastModifiedDateTime] DATETIME2 (7)    NOT NULL,
    [LastModifiedDTOffset] INT              NOT NULL,
    [Notes]                NVARCHAR (1024)  NOT NULL,
    [Version]              INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_Flow_Notes] PRIMARY KEY CLUSTERED ([FlowExecID] ASC, [LastModifiedDateTime] ASC)
);

