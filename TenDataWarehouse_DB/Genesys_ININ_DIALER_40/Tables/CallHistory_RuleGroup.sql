CREATE TABLE [Genesys_ININ_DIALER_40].[CallHistory_RuleGroup] (
    [ActiveRuleGroupName] NVARCHAR (80)    NOT NULL,
    [RuleGroupId]         SMALLINT         NOT NULL,
    [RuleSetId]           UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_ININ_DIALER_40_CallHistory_RuleGroup] PRIMARY KEY CLUSTERED ([RuleGroupId] ASC)
);

