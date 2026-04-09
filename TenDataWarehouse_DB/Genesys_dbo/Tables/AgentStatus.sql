CREATE TABLE [Genesys_dbo].[AgentStatus] (
    [StatisticsSet]        INT NOT NULL,
    [tAgentStatusAcw]      INT NOT NULL,
    [tAgentStatusDnd]      INT NOT NULL,
    [tStatusGroupBreak]    INT NOT NULL,
    [tStatusGroupFollowup] INT NOT NULL,
    [tStatusGroupTraining] INT NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_AgentStatus] PRIMARY KEY CLUSTERED ([StatisticsSet] ASC)
);

