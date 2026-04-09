CREATE TABLE [Genesys_dbo].[LineConfig] (
    [ActiveFlag]     SMALLINT      NOT NULL,
    [Direction]      VARCHAR (20)  NOT NULL,
    [I3TimeStampGMT] DATETIME      NOT NULL,
    [LineId]         NVARCHAR (50) NOT NULL,
    [LineType]       VARCHAR (50)  NOT NULL,
    [PhoneNumber]    VARCHAR (20)  NULL,
    [SiteId]         SMALLINT      NOT NULL,
    [SubSiteId]      SMALLINT      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_LineConfig] PRIMARY KEY CLUSTERED ([LineId] ASC, [SiteId] ASC)
);

