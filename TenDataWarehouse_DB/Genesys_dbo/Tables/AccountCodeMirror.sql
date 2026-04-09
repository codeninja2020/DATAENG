CREATE TABLE [Genesys_dbo].[AccountCodeMirror] (
    [AccountCode]    NVARCHAR (50)  NOT NULL,
    [Description]    NVARCHAR (128) NOT NULL,
    [I3TimeStampGMT] DATETIME       NOT NULL,
    [SiteId]         SMALLINT       NOT NULL,
    [SubSiteId]      SMALLINT       NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_AccountCodeMirror] PRIMARY KEY CLUSTERED ([AccountCode] ASC, [SiteId] ASC)
);

