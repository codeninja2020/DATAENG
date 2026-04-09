CREATE TABLE [Genesys_dbo].[IO_ServiceGoalGroup] (
    [AverageSpeedOfAnswerSecs] INT            NOT NULL,
    [ModifierUserID]           NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]        DATETIME       NOT NULL,
    [Name]                     NVARCHAR (100) NOT NULL,
    [SchedulingUnitID]         CHAR (22)      NOT NULL,
    [ServiceGoalGroupID]       CHAR (22)      NOT NULL,
    [ServiceLevelPercent]      INT            NOT NULL,
    [ServiceLevelSecs]         INT            NOT NULL,
    [UseAverageSpeedOfAnswer]  TINYINT        NOT NULL,
    [UseServiceLevel]          TINYINT        NOT NULL,
    [Version]                  INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ServiceGoalGroup] PRIMARY KEY CLUSTERED ([ServiceGoalGroupID] ASC)
);

