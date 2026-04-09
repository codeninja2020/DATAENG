CREATE TABLE [Genesys_dbo].[DirectorWrkGrpStatistics] (
    [nProcessEntered] INT NOT NULL,
    [nProcessFail]    INT NOT NULL,
    [nProcessSuccess] INT NOT NULL,
    [nRemoteAnswered] INT NOT NULL,
    [nRouteAnswered]  INT NOT NULL,
    [nRouteEntered]   INT NOT NULL,
    [nRouteFail]      INT NOT NULL,
    [nRouteSuccess]   INT NOT NULL,
    [StatisticsSet]   INT NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_DirectorWrkGrpStatistics] PRIMARY KEY CLUSTERED ([StatisticsSet] ASC)
);

