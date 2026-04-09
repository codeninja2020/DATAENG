CREATE TABLE [Genesys_dbo].[IWrapUpStats] (
    [cHKey3]              NVARCHAR (50) NOT NULL,
    [cHKey4]              NVARCHAR (50) NOT NULL,
    [cName]               NVARCHAR (50) NOT NULL,
    [cReportGroup]        NVARCHAR (50) NOT NULL,
    [cType]               CHAR (1)      NOT NULL,
    [dIntervalStart]      DATETIME      NOT NULL,
    [I3TimeStampGMT]      DATETIME      NOT NULL,
    [nCompleted]          INT           NOT NULL,
    [nDuration]           INT           NOT NULL,
    [nHold]               INT           NOT NULL,
    [nSupervisorRequests] INT           NOT NULL,
    [nSuspended]          INT           NOT NULL,
    [SiteId]              SMALLINT      NOT NULL,
    [SubSiteId]           SMALLINT      NOT NULL,
    [tAcw]                INT           NOT NULL,
    [tHold]               INT           NOT NULL,
    [tSuspended]          INT           NOT NULL,
    [tTalked]             INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IWrapUpStats] PRIMARY KEY CLUSTERED ([cHKey3] ASC, [cHKey4] ASC, [cName] ASC, [cReportGroup] ASC, [cType] ASC, [dIntervalStart] ASC, [I3TimeStampGMT] ASC, [SiteId] ASC)
);

