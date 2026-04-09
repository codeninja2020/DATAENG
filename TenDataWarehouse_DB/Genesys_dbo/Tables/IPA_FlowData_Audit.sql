CREATE TABLE [Genesys_dbo].[IPA_FlowData_Audit] (
    [ActionExecID]         UNIQUEIDENTIFIER NOT NULL,
    [DataElementID]        NVARCHAR (36)    NOT NULL,
    [DataElementValue]     XML              NULL,
    [FlowExecID]           UNIQUEIDENTIFIER NOT NULL,
    [LastModifiedDateTime] DATETIME         NOT NULL,
    [Version]              INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_FlowData_Audit] PRIMARY KEY CLUSTERED ([ActionExecID] ASC, [DataElementID] ASC, [FlowExecID] ASC)
);

