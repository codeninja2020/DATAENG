CREATE TABLE [Genesys_Cloud].[ParticipantAttrs_Staging] (
    [conversationId]       NVARCHAR (128) NOT NULL,
    [participantId]        NVARCHAR (128) NOT NULL,
    [attrName]             NVARCHAR (128) NOT NULL,
    [attrValue]            NVARCHAR (MAX) NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_dbo.ParticipantAttrs_Staging] PRIMARY KEY CLUSTERED ([conversationId] ASC, [participantId] ASC, [attrName] ASC)
);

