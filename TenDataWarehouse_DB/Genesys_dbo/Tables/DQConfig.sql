CREATE TABLE [Genesys_dbo].[DQConfig] (
    [ConfigurationSet]  INT            NOT NULL,
    [cServiceLevels]    VARCHAR (1024) NULL,
    [dIntervalStartUTC] DATETIME       NOT NULL,
    [nServiceLevel]     INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_DQConfig] PRIMARY KEY CLUSTERED ([ConfigurationSet] ASC)
);

