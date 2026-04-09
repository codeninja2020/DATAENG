CREATE TABLE [Genesys_Cloud].[Participants_Staging] (
    [RowId]                       BIGINT         NOT NULL,
    [participantId]               NVARCHAR (MAX) NULL,
    [participantName]             NVARCHAR (MAX) NULL,
    [userId]                      NVARCHAR (MAX) NULL,
    [purpose]                     NVARCHAR (MAX) NULL,
    [externalContactId]           NVARCHAR (MAX) NULL,
    [externalOrganizationId]      NVARCHAR (MAX) NULL,
    [Conversation_conversationId] NVARCHAR (128) NULL,
    [InsertedOn]                  DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION]        NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]          BIGINT         NULL,
    CONSTRAINT [PK_Genesys_Cloud.Participants_Staging] PRIMARY KEY CLUSTERED ([RowId] ASC)
);

