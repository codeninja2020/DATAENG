CREATE TABLE [Genesys_Cloud].[Conversations] (
    [conversationId]    NVARCHAR (128) NOT NULL,
    [conversationStart] DATETIME       NULL,
    [conversationEnd]   DATETIME       NULL,
    [InsertedOn]        DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.Conversations] PRIMARY KEY CLUSTERED ([conversationId] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Conversations] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

