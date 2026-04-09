CREATE TABLE [Genesys_dbo].[SurveyConfigLog] (
    [ConfigChangeObjectType] INT      NOT NULL,
    [ConfigChangeType]       INT      NOT NULL,
    [ConfigTimeStampUTC]     DATETIME NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyConfigLog] PRIMARY KEY CLUSTERED ([ConfigChangeObjectType] ASC, [ConfigChangeType] ASC, [ConfigTimeStampUTC] ASC)
);

