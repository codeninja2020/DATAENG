CREATE TABLE [Genesys_dbo].[flowexec_Flows] (
    [Attributes]     NVARCHAR (MAX)   NULL,
    [ExecID]         UNIQUEIDENTIFIER NOT NULL,
    [FlowConfigID]   UNIQUEIDENTIFIER NOT NULL,
    [FlowConfigRev]  NVARCHAR (30)    NOT NULL,
    [FlowExecID]     UNIQUEIDENTIFIER NOT NULL,
    [LaunchMode]     SMALLINT         NOT NULL,
    [StorageOwnerID] UNIQUEIDENTIFIER NOT NULL,
    [Type]           SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_flowexec_Flows] PRIMARY KEY CLUSTERED ([ExecID] ASC)
);

