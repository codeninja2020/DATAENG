CREATE TABLE [Genesys_dbo].[EE_FlowOutEvents] (
    [EventDateTimeUTC] DATETIME2 (7)    NOT NULL,
    [EventDTOffset]    INT              NOT NULL,
    [InteractionIDKey] CHAR (18)        NOT NULL,
    [SerialKey]        UNIQUEIDENTIFIER NOT NULL,
    [SiteID]           SMALLINT         NOT NULL,
    [SourceQueueId]    BIGINT           NOT NULL,
    [SourceQueueType]  SMALLINT         NOT NULL,
    [TargetQueueId]    BIGINT           NOT NULL,
    [TargetQueueType]  SMALLINT         NULL,
    [TimeInQueue]      BIGINT           NULL,
    CONSTRAINT [PK_Genesys_dbo_EE_FlowOutEvents] PRIMARY KEY CLUSTERED ([SerialKey] ASC)
);

