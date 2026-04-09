CREATE TABLE [Genesys_dbo].[LineGroupConfig] (
    [Description]    NVARCHAR (50) NOT NULL,
    [DialGroupFlag]  SMALLINT      NOT NULL,
    [GroupId]        NVARCHAR (50) NOT NULL,
    [I3TimeStampGMT] DATETIME      NOT NULL,
    [ReportFlag]     SMALLINT      NOT NULL,
    [SiteId]         SMALLINT      NOT NULL,
    [SubSiteId]      SMALLINT      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_LineGroupConfig] PRIMARY KEY CLUSTERED ([GroupId] ASC, [SiteId] ASC)
);

