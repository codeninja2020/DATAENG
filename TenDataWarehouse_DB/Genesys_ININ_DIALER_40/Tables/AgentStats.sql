CREATE TABLE [Genesys_ININ_DIALER_40].[AgentStats] (
    [agentid]       VARCHAR (80)  NOT NULL,
    [agentstats_id] BIGINT        NOT NULL,
    [agenttimeUTC]  DATETIME      NOT NULL,
    [callid]        VARCHAR (11)  NULL,
    [callidkey]     VARCHAR (18)  NULL,
    [campaignname]  VARCHAR (255) NULL,
    [odsoffset]     INT           NOT NULL,
    [propertyname]  VARCHAR (255) NOT NULL,
    [propertyvalue] VARCHAR (255) NULL,
    [siteid]        VARCHAR (80)  NOT NULL,
    [stageid]       VARCHAR (10)  NULL,
    CONSTRAINT [PK_Genesys_ININ_DIALER_40_AgentStats] PRIMARY KEY CLUSTERED ([agentstats_id] ASC)
);

