CREATE TABLE [Genesys_Cloud].[Genesys_participantattrs_backup_20240110] (
    [conversationId] NVARCHAR (128) NOT NULL,
    [participantId]  NVARCHAR (128) NOT NULL,
    [attrName]       NVARCHAR (128) NOT NULL,
    [attrValue]      NVARCHAR (MAX) NULL,
    [InsertedOn]     DATETIME       NOT NULL
);

