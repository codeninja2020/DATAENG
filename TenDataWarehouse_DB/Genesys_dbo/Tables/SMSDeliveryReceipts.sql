CREATE TABLE [Genesys_dbo].[SMSDeliveryReceipts] (
    [AttemptCount]     INT           NOT NULL,
    [Broker]           NVARCHAR (50) NOT NULL,
    [FailureCount]     INT           NOT NULL,
    [InteractionID]    BIGINT        NOT NULL,
    [InteractionIDKey] CHAR (18)     NOT NULL,
    [SeqNo]            TINYINT       NOT NULL,
    [SiteID]           SMALLINT      NOT NULL,
    [StartDateTimeUTC] DATETIME2 (7) NOT NULL,
    [SuccessCount]     INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SMSDeliveryReceipts] PRIMARY KEY CLUSTERED ([InteractionIDKey] ASC, [SeqNo] ASC, [SiteID] ASC)
);

