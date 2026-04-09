CREATE TABLE [Genesys_Cloud].[Segments] (
    [RowId]                     BIGINT         NOT NULL,
    [segmentStart]              DATETIME       NULL,
    [segmentEnd]                DATETIME       NULL,
    [queueId]                   NVARCHAR (MAX) NULL,
    [wrapUpCode]                NVARCHAR (MAX) NULL,
    [wrapUpNote]                NVARCHAR (MAX) NULL,
    [errorCode]                 NVARCHAR (MAX) NULL,
    [disconnectType]            NVARCHAR (MAX) NULL,
    [segmentType]               NVARCHAR (MAX) NULL,
    [requestedLanguageId]       NVARCHAR (MAX) NULL,
    [sourceConversationId]      NVARCHAR (MAX) NULL,
    [destinationConversationId] NVARCHAR (MAX) NULL,
    [sourceSessionId]           NVARCHAR (MAX) NULL,
    [destinationSessionId]      NVARCHAR (MAX) NULL,
    [conference]                BIT            NULL,
    [groupId]                   NVARCHAR (MAX) NULL,
    [subject]                   NVARCHAR (MAX) NULL,
    [audioMuted]                BIT            NULL,
    [videoMuted]                BIT            NULL,
    [Session_RowId]             BIGINT         NULL,
    [InsertedOn]                DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.Segments] PRIMARY KEY CLUSTERED ([RowId] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Segments] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);


GO
CREATE NONCLUSTERED INDEX [IX_Segments_Session_RowId]
    ON [Genesys_Cloud].[Segments]([Session_RowId] ASC);

