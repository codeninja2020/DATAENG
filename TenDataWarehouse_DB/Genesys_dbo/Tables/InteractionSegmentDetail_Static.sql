CREATE TABLE [Genesys_dbo].[InteractionSegmentDetail_Static] (
    [ConversationID]   VARCHAR (24)  NULL,
    [InteractionIDKey] CHAR (18)     NOT NULL,
    [SegmentLog]       INT           NULL,
    [SeqNo]            TINYINT       NOT NULL,
    [SiteID]           SMALLINT      NOT NULL,
    [StartDateTimeUTC] DATETIME2 (7) NOT NULL,
    [StartDTOffset]    INT           NOT NULL
);

