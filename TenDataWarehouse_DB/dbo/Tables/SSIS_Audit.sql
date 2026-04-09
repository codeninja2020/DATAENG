CREATE TABLE [dbo].[SSIS_Audit] (
    [AuditId]     INT              IDENTITY (1, 1) NOT NULL,
    [TableId]     VARCHAR (500)    NULL,
    [SourceId]    UNIQUEIDENTIFIER NULL,
    [Description] VARCHAR (4000)   NULL,
    [InsertedOn]  DATETIME         NULL,
    CONSTRAINT [PK_SSIS_Audit_AuditId] PRIMARY KEY CLUSTERED ([AuditId] ASC)
);

