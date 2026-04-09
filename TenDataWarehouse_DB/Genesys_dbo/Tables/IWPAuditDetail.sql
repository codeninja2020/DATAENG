CREATE TABLE [Genesys_dbo].[IWPAuditDetail] (
    [AuditDetailId]   UNIQUEIDENTIFIER NOT NULL,
    [AuditId]         UNIQUEIDENTIFIER NOT NULL,
    [NewValue]        NVARCHAR (50)    NULL,
    [ObjectAttribute] NVARCHAR (48)    NOT NULL,
    [OldValue]        NVARCHAR (50)    NULL,
    CONSTRAINT [PK_Genesys_dbo_IWPAuditDetail] PRIMARY KEY CLUSTERED ([AuditDetailId] ASC)
);

