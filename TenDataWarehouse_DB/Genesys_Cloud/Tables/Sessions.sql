CREATE TABLE [Genesys_Cloud].[Sessions] (
    [RowId]                  BIGINT         NOT NULL,
    [mediaType]              NVARCHAR (MAX) NULL,
    [sessionId]              NVARCHAR (MAX) NULL,
    [addressOther]           NVARCHAR (MAX) NULL,
    [addressSelf]            NVARCHAR (MAX) NULL,
    [ani]                    NVARCHAR (MAX) NULL,
    [direction]              NVARCHAR (MAX) NULL,
    [dnis]                   NVARCHAR (MAX) NULL,
    [outboundCampaignId]     NVARCHAR (MAX) NULL,
    [outboundContactId]      NVARCHAR (MAX) NULL,
    [outboundContactListId]  NVARCHAR (MAX) NULL,
    [dispositionAnalyzer]    NVARCHAR (MAX) NULL,
    [dispositionName]        NVARCHAR (MAX) NULL,
    [edgeId]                 NVARCHAR (MAX) NULL,
    [remoteNameDisplayable]  NVARCHAR (MAX) NULL,
    [roomId]                 NVARCHAR (MAX) NULL,
    [monitoredSessionId]     NVARCHAR (MAX) NULL,
    [monitoredParticipantId] NVARCHAR (MAX) NULL,
    [callbackUserName]       NVARCHAR (MAX) NULL,
    [callbackScheduledTime]  DATETIME       NULL,
    [scriptId]               NVARCHAR (MAX) NULL,
    [skipEnabled]            BIT            NULL,
    [timeoutSeconds]         INT            NULL,
    [cobrowseRole]           NVARCHAR (MAX) NULL,
    [cobrowseRoomId]         NVARCHAR (MAX) NULL,
    [mediaBridgeId]          NVARCHAR (MAX) NULL,
    [screenShareAddressSelf] NVARCHAR (MAX) NULL,
    [sharingScreen]          BIT            NULL,
    [screenShareRoomId]      NVARCHAR (MAX) NULL,
    [videoRoomId]            NVARCHAR (MAX) NULL,
    [videoAddressSelf]       NVARCHAR (MAX) NULL,
    [Participant_RowId]      BIGINT         NULL,
    [InsertedOn]             DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.Sessions] PRIMARY KEY CLUSTERED ([RowId] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Sessions] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);


GO
CREATE NONCLUSTERED INDEX [IX_Sessions_Participant_RowId]
    ON [Genesys_Cloud].[Sessions]([Participant_RowId] ASC) WITH (DATA_COMPRESSION = PAGE);

