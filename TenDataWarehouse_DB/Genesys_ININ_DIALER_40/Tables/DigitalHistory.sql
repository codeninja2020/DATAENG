CREATE TABLE [Genesys_ININ_DIALER_40].[DigitalHistory] (
    [associated_callid]    CHAR (19)      NULL,
    [digital_type]         TINYINT        NULL,
    [email_subject]        NVARCHAR (MAX) NULL,
    [interactionid]        CHAR (19)      NOT NULL,
    [policy_behavior_name] NVARCHAR (30)  NULL,
    [recipient]            NVARCHAR (255) NULL,
    [sender]               NVARCHAR (255) NULL,
    [time_queued_utc]      DATETIME2 (7)  NULL,
    [DigitalHistoryId]     INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_Genesys_ININ_DIALER_40_DigitalHistoryId] PRIMARY KEY CLUSTERED ([DigitalHistoryId] ASC)
);

