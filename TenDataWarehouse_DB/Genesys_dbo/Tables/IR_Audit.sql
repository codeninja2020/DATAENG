CREATE TABLE [Genesys_dbo].[IR_Audit] (
    [AuditDate]       DATETIME         NOT NULL,
    [AuditDateOffset] INT              NOT NULL,
    [AuditedName]     NVARCHAR (255)   NULL,
    [AuditId]         UNIQUEIDENTIFIER NOT NULL,
    [AuditOperation]  SMALLINT         NOT NULL,
    [Comments]        NVARCHAR (1024)  NULL,
    [ICUID]           NVARCHAR (255)   NULL,
    [Id]              UNIQUEIDENTIFIER NOT NULL,
    [IndivId]         CHAR (22)        NULL,
    [Version]         INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_Audit] PRIMARY KEY CLUSTERED ([AuditId] ASC)
);

