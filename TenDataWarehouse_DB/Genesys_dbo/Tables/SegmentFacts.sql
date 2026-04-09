CREATE TABLE [Genesys_dbo].[SegmentFacts] (
    [Active]             BIT            NULL,
    [Agent]              NVARCHAR (50)  NULL,
    [Answered]           BIT            NULL,
    [AnsweredByAgent]    BIT            NULL,
    [Details]            NVARCHAR (MAX) NULL,
    [Duration]           NUMERIC (18)   NULL,
    [HandledByWG]        BIT            NULL,
    [HowEnded]           TINYINT        NULL,
    [InteractionIDKey]   CHAR (18)      NOT NULL,
    [Remotedisconnected] BIT            NULL,
    [SameWGTransfer]     BIT            NULL,
    [SegmentStart]       DATETIME2 (7)  NULL,
    [SegmentType]        INT            NULL,
    [SegNo]              SMALLINT       NOT NULL,
    [SiteID]             SMALLINT       NOT NULL,
    [WGTransfer]         BIT            NULL,
    [Workgroup]          NVARCHAR (100) NULL,
    [WrapupCode]         NVARCHAR (200) NULL,
    CONSTRAINT [PK_Genesys_dbo_SegmentFacts] PRIMARY KEY CLUSTERED ([InteractionIDKey] ASC, [SegNo] ASC, [SiteID] ASC)
);

