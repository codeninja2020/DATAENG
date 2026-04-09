CREATE TABLE [Genesys_dbo].[ETLBookmarks] (
    [ErrCode]          TINYINT   NOT NULL,
    [InteractionIDKey] CHAR (18) NOT NULL,
    [SeqNo]            TINYINT   NOT NULL,
    [SiteID]           SMALLINT  NOT NULL,
    [Version]          INT       NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_ETLBookmarks] PRIMARY KEY CLUSTERED ([InteractionIDKey] ASC, [SiteID] ASC)
);

