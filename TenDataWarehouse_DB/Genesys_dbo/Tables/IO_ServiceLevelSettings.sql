CREATE TABLE [Genesys_dbo].[IO_ServiceLevelSettings] (
    [AverageSpeedOfAnswer]    INT            NOT NULL,
    [DefaultSettings]         TINYINT        NOT NULL,
    [ModifierUserID]          NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]       DATETIME       NULL,
    [ServiceLevel]            TINYINT        NOT NULL,
    [ServiceLevelObjective]   INT            NOT NULL,
    [ServiceLevelSettingsID]  CHAR (22)      NOT NULL,
    [StartTimeUTC]            DATETIME       NOT NULL,
    [StopTimeUTC]             DATETIME       NOT NULL,
    [UseAverageSpeedOfAnswer] TINYINT        NOT NULL,
    [UseServiceLevel]         TINYINT        NOT NULL,
    [Version]                 INT            NOT NULL,
    [WorkgroupID]             CHAR (22)      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ServiceLevelSettings] PRIMARY KEY CLUSTERED ([ServiceLevelSettingsID] ASC)
);

