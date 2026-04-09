CREATE TABLE [Genesys_dbo].[StatProfile] (
    [ConfigurationSet]   INT      NOT NULL,
    [DimensionSet]       INT      NOT NULL,
    [dIntervalStart]     DATETIME NOT NULL,
    [dIntervalStartUTC]  DATETIME NULL,
    [I3TimeStampGMT]     DATETIME NOT NULL,
    [nDuration]          INT      NOT NULL,
    [SchemaMajorVersion] TINYINT  NOT NULL,
    [SchemaMinorVersion] TINYINT  NOT NULL,
    [SiteId]             SMALLINT NOT NULL,
    [StatisticsSet]      INT      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_StatProfile] PRIMARY KEY CLUSTERED ([StatisticsSet] ASC)
);

