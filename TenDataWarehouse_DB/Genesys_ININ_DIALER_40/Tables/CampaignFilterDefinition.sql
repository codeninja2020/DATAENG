CREATE TABLE [Genesys_ININ_DIALER_40].[CampaignFilterDefinition] (
    [CampaignFilterId] SMALLINT         NOT NULL,
    [FilterId]         UNIQUEIDENTIFIER NOT NULL,
    [FilterName]       NVARCHAR (80)    NULL,
    CONSTRAINT [PK_Genesys_ININ_DIALER_40_CampaignFilterDefinition] PRIMARY KEY CLUSTERED ([CampaignFilterId] ASC, [FilterId] ASC)
);

