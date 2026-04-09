CREATE TABLE [Genesys_dbo].[ICDirChangeLog] (
    [ChangeDateTime]    DATETIME       NOT NULL,
    [ChangeDateTimeGMT] DATETIME       NOT NULL,
    [ChangeTime]        CHAR (8)       NOT NULL,
    [EntryClass]        NVARCHAR (50)  NOT NULL,
    [EntryName]         NVARCHAR (50)  NOT NULL,
    [EntryPath]         NVARCHAR (128) NOT NULL,
    [I3TimeStampGMT]    DATETIME       NOT NULL,
    [ListOfAttributes]  NVARCHAR (255) NULL,
    [NotificationType]  VARCHAR (50)   NOT NULL,
    [SiteId]            SMALLINT       NOT NULL,
    [SubSiteId]         SMALLINT       NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_ICDirChangeLog] PRIMARY KEY CLUSTERED ([ChangeDateTimeGMT] ASC, [EntryClass] ASC, [EntryName] ASC, [EntryPath] ASC, [NotificationType] ASC, [SiteId] ASC)
);

