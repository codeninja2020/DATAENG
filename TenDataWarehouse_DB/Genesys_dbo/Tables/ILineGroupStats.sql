CREATE TABLE [Genesys_dbo].[ILineGroupStats] (
    [dIntervalStart]     DATETIME      NOT NULL,
    [GroupId]            NVARCHAR (50) NOT NULL,
    [I3TimeStampGMT]     DATETIME      NOT NULL,
    [mEntered]           INT           NOT NULL,
    [nDuration]          SMALLINT      NOT NULL,
    [nEntered]           INT           NOT NULL,
    [nEnteredOutbound]   INT           NOT NULL,
    [nOutboundBlocked]   INT           NOT NULL,
    [SiteId]             SMALLINT      NOT NULL,
    [SubSiteId]          SMALLINT      NOT NULL,
    [tActiveLines]       INT           NOT NULL,
    [tAllBusy]           INT           NOT NULL,
    [tResourceAvailable] INT           NOT NULL,
    [tSeized]            INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_ILineGroupStats] PRIMARY KEY CLUSTERED ([dIntervalStart] ASC, [GroupId] ASC, [I3TimeStampGMT] ASC, [nDuration] ASC, [SiteId] ASC)
);

