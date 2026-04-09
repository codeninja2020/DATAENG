CREATE TABLE [Genesys_dbo].[EE_AbandonEvents] (
    [EventDateTimeUTC] DATETIME2 (7)    NOT NULL,
    [EventDTOffset]    INT              NOT NULL,
    [InteractionIDKey] CHAR (18)        NOT NULL,
    [SerialKey]        UNIQUEIDENTIFIER NOT NULL,
    [SiteID]           SMALLINT         NOT NULL,
    [SourceQueueId]    BIGINT           NOT NULL,
    [SourceQueueType]  SMALLINT         NOT NULL,
    [TimeInQueue]      BIGINT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_EE_AbandonEvents] PRIMARY KEY CLUSTERED ([SerialKey] ASC)
);

