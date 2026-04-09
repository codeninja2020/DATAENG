CREATE TABLE [Genesys_Cloud].[ParticipantAttrs] (
    [conversationId] NVARCHAR (128)  NOT NULL,
    [participantId]  NVARCHAR (128)  NOT NULL,
    [attrName]       NVARCHAR (128)  NOT NULL,
    [attrValue]      NVARCHAR (4000) NULL,
    [InsertedOn]     DATETIME        NOT NULL,
    CONSTRAINT [PK_ParticipantAttrs_Id] PRIMARY KEY CLUSTERED ([conversationId] ASC, [participantId] ASC, [attrName] ASC) WITH (DATA_COMPRESSION = PAGE)
);


GO
ALTER TABLE [Genesys_Cloud].[ParticipantAttrs] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);


GO
CREATE NONCLUSTERED INDEX [IX_ParticipantAttrs_attrName_conversationId]
    ON [Genesys_Cloud].[ParticipantAttrs]([attrName] ASC, [InsertedOn] ASC, [conversationId] ASC)
    INCLUDE([attrValue]) WITH (DATA_COMPRESSION = PAGE);

