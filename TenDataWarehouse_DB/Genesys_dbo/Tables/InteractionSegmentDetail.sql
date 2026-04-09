CREATE TABLE [Genesys_dbo].[InteractionSegmentDetail] (
    [ConversationID]   VARCHAR (24)   NULL,
    [InteractionIDKey] CHAR (18)      NOT NULL,
    [SegmentLog]       NVARCHAR (MAX) NULL,
    [SeqNo]            TINYINT        NOT NULL,
    [SiteID]           SMALLINT       NOT NULL,
    [StartDateTimeUTC] DATETIME2 (7)  NOT NULL,
    [StartDTOffset]    INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_InteractionSegmentDetail] PRIMARY KEY CLUSTERED ([InteractionIDKey] ASC, [SeqNo] ASC, [SiteID] ASC)
);

