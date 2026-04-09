CREATE TABLE [Genesys_dbo].[AgentQueueActivationHist] (
    [AgentQueueActivationHist] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ActivatedBy]              NVARCHAR (50) NULL,
    [ActivationDateTime]       DATETIME      NOT NULL,
    [ActivationDateTimeGMT]    DATETIME      NOT NULL,
    [ActivationFlag]           SMALLINT      NOT NULL,
    [HasQueueFlag]             SMALLINT      NOT NULL,
    [I3TimeStampGMT]           DATETIME      NOT NULL,
    [SiteId]                   SMALLINT      NOT NULL,
    [SubSiteId]                SMALLINT      NOT NULL,
    [UserId]                   NVARCHAR (50) NULL,
    [Workgroup]                NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_AgentQueueActivationHist] PRIMARY KEY CLUSTERED ([AgentQueueActivationHist] ASC)
);

