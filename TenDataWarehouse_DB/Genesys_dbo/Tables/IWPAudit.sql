CREATE TABLE [Genesys_dbo].[IWPAudit] (
    [AuditId]          UNIQUEIDENTIFIER NOT NULL,
    [AuditTimeOffset]  SMALLINT         NOT NULL,
    [AuditTimeUTC]     DATETIME         NOT NULL,
    [EventType]        SMALLINT         NOT NULL,
    [ICUserId]         NVARCHAR (50)    NOT NULL,
    [IndivId]          CHAR (22)        NOT NULL,
    [Notes]            NVARCHAR (256)   NULL,
    [ObjectId]         UNIQUEIDENTIFIER NULL,
    [ObjectName]       NVARCHAR (48)    NULL,
    [ObjectType]       SMALLINT         NOT NULL,
    [OrganizationId]   UNIQUEIDENTIFIER NULL,
    [OrganizationName] NVARCHAR (48)    NULL,
    [ResultCode]       SMALLINT         NULL,
    [ResultText]       NVARCHAR (256)   NULL,
    [SiteId]           SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IWPAudit] PRIMARY KEY CLUSTERED ([AuditId] ASC)
);

