CREATE TABLE [Genesys_dbo].[IPA_Entities] (
    [FlowID]        UNIQUEIDENTIFIER NOT NULL,
    [MajorRevision] INT              NOT NULL,
    [MinorRevision] INT              NOT NULL,
    [ObjectID]      UNIQUEIDENTIFIER NOT NULL,
    [ObjectName]    NVARCHAR (128)   NULL,
    [SiteId]        SMALLINT         NOT NULL,
    [Version]       INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_Entities] PRIMARY KEY CLUSTERED ([MajorRevision] ASC, [MinorRevision] ASC, [ObjectID] ASC, [SiteId] ASC)
);

