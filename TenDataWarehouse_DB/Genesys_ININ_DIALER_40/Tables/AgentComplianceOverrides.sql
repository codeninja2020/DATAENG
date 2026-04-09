CREATE TABLE [Genesys_ININ_DIALER_40].[AgentComplianceOverrides] (
    [id]                         SMALLINT NOT NULL,
    [Filter]                     BIT      NULL,
    [QueryTimeFilter]            BIT      NULL,
    [ZoneBlocking]               BIT      NULL,
    [Skills]                     BIT      NULL,
    [DailyLimit]                 BIT      NULL,
    [MinimumSpacing]             BIT      NULL,
    [PNDStatus]                  BIT      NULL,
    [DNCScrub]                   BIT      NULL,
    [CampaignOwnership]          BIT      NULL,
    [AgentComplianceOverridesId] INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_Genesys_ININ_DIALER_40_AgentComplianceOverridesId] PRIMARY KEY CLUSTERED ([AgentComplianceOverridesId] ASC)
);

