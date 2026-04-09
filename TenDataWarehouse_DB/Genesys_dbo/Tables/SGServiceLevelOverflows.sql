CREATE TABLE [Genesys_dbo].[SGServiceLevelOverflows] (
    [nAbandonAcdSvcLvl1]  INT NULL,
    [nAbandonAcdSvcLvl2]  INT NULL,
    [nAbandonAcdSvcLvl3]  INT NULL,
    [nAbandonAcdSvcLvl4]  INT NULL,
    [nAbandonAcdSvcLvl5]  INT NULL,
    [nAbandonAcdSvcLvl6]  INT NULL,
    [nAnsweredAcdSvcLvl1] INT NULL,
    [nAnsweredAcdSvcLvl2] INT NULL,
    [nAnsweredAcdSvcLvl3] INT NULL,
    [nAnsweredAcdSvcLvl4] INT NULL,
    [nAnsweredAcdSvcLvl5] INT NULL,
    [nAnsweredAcdSvcLvl6] INT NULL,
    [OverflowGroupSet]    INT NOT NULL,
    [StatisticsSet]       INT NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SGServiceLevelOverflows] PRIMARY KEY CLUSTERED ([OverflowGroupSet] ASC, [StatisticsSet] ASC)
);

