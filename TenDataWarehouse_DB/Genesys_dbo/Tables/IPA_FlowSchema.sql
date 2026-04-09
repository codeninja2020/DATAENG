CREATE TABLE [Genesys_dbo].[IPA_FlowSchema] (
    [FlowID]            UNIQUEIDENTIFIER NOT NULL,
    [FLowMajorRevision] INT              NOT NULL,
    [FlowMinorRevision] INT              NOT NULL,
    [SiteId]            SMALLINT         NOT NULL,
    [Version]           INT              NOT NULL,
    [XMLSchema]         XML              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_FlowSchema] PRIMARY KEY CLUSTERED ([FlowID] ASC, [FLowMajorRevision] ASC, [FlowMinorRevision] ASC, [SiteId] ASC)
);

