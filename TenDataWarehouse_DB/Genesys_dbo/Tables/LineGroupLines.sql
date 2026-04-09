CREATE TABLE [Genesys_dbo].[LineGroupLines] (
    [GroupId]        NVARCHAR (50) NOT NULL,
    [I3TimeStampGMT] DATETIME      NOT NULL,
    [LineId]         NVARCHAR (50) NOT NULL,
    [SiteId]         SMALLINT      NOT NULL,
    [SubSiteId]      SMALLINT      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_LineGroupLines] PRIMARY KEY CLUSTERED ([GroupId] ASC, [LineId] ASC, [SiteId] ASC)
);

