CREATE TABLE [Genesys_Cloud].[Participants] (
    [RowId]                       BIGINT         NOT NULL,
    [participantId]               NVARCHAR (MAX) NULL,
    [participantName]             NVARCHAR (MAX) NULL,
    [userId]                      NVARCHAR (MAX) NULL,
    [purpose]                     NVARCHAR (MAX) NULL,
    [externalContactId]           NVARCHAR (MAX) NULL,
    [externalOrganizationId]      NVARCHAR (MAX) NULL,
    [Conversation_conversationId] NVARCHAR (128) NULL,
    [InsertedOn]                  DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.Participants] PRIMARY KEY CLUSTERED ([RowId] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Participants] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);


GO
CREATE NONCLUSTERED INDEX [IX_Participants_Conversation_conversationId]
    ON [Genesys_Cloud].[Participants]([Conversation_conversationId] ASC);

