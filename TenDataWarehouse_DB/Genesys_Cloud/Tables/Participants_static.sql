CREATE TABLE [Genesys_Cloud].[Participants_static] (
    [RowId]                       BIGINT         NOT NULL,
    [participantId]               NVARCHAR (MAX) NULL,
    [participantName]             INT            NULL,
    [userId]                      NVARCHAR (MAX) NULL,
    [purpose]                     NVARCHAR (MAX) NULL,
    [externalContactId]           NVARCHAR (MAX) NULL,
    [externalOrganizationId]      NVARCHAR (MAX) NULL,
    [Conversation_conversationId] NVARCHAR (128) NULL
);

