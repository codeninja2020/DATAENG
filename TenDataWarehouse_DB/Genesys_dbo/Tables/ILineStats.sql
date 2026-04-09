CREATE TABLE [Genesys_dbo].[ILineStats] (
    [dIntervalStart]     DATETIME      NOT NULL,
    [I3TimeStampGMT]     DATETIME      NOT NULL,
    [LineId]             NVARCHAR (50) NOT NULL,
    [nDuration]          SMALLINT      NOT NULL,
    [nEntered]           INT           NOT NULL,
    [nEnteredOutbound]   INT           NOT NULL,
    [nOutboundBlocked]   INT           NOT NULL,
    [SiteId]             SMALLINT      NOT NULL,
    [SubSiteId]          SMALLINT      NOT NULL,
    [tResourceAvailable] INT           NOT NULL,
    [tSeized]            INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_ILineStats] PRIMARY KEY CLUSTERED ([dIntervalStart] ASC, [I3TimeStampGMT] ASC, [LineId] ASC, [SiteId] ASC)
);

