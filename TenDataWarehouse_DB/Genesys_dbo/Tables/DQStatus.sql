CREATE TABLE [Genesys_dbo].[DQStatus] (
    [StatisticsSet]         INT NOT NULL,
    [tAgentAcdLoggedIn]     INT NOT NULL,
    [tAgentAcdLoggedIn2]    INT NOT NULL,
    [tAgentAvailable]       INT NOT NULL,
    [tAgentDnd]             INT NOT NULL,
    [tAgentInAcw]           INT NOT NULL,
    [tAgentLoggedIn]        INT NOT NULL,
    [tAgentLoggedInDiluted] INT NOT NULL,
    [tAgentNotAvailable]    INT NOT NULL,
    [tAgentOnAcdCall]       INT NOT NULL,
    [tAgentOnNonAcdCall]    INT NOT NULL,
    [tAgentOnOtherAcdCall]  INT NOT NULL,
    [tAgentOtherBusy]       INT NOT NULL,
    [tAgentStatusAcw]       INT NOT NULL,
    [tAgentStatusDnd]       INT NOT NULL,
    [tStatusGroupBreak]     INT NOT NULL,
    [tStatusGroupFollowup]  INT NOT NULL,
    [tStatusGroupTraining]  INT NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_DQStatus] PRIMARY KEY CLUSTERED ([StatisticsSet] ASC)
);

