CREATE TABLE [Genesys_dbo].[EE_TransferEvents] (
    [EventDateTimeUTC] DATETIME2 (7)    NOT NULL,
    [EventDTOffset]    INT              NOT NULL,
    [InteractionIDKey] CHAR (18)        NOT NULL,
    [SerialKey]        UNIQUEIDENTIFIER NOT NULL,
    [SiteID]           SMALLINT         NOT NULL,
    [SourceQueueId]    BIGINT           NOT NULL,
    [SourceUserId]     BIGINT           NOT NULL,
    [TargetQueueId]    BIGINT           NOT NULL,
    [TargetUserId]     BIGINT           NOT NULL,
    [TimeInSrcQueue]   BIGINT           NULL,
    [TransferType]     SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_EE_TransferEvents] PRIMARY KEY CLUSTERED ([SerialKey] ASC)
);

