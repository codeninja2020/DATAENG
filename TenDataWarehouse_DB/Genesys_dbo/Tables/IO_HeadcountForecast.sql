CREATE TABLE [Genesys_dbo].[IO_HeadcountForecast] (
    [ForecastScheduleEntryID] CHAR (22)      NOT NULL,
    [GenerationMethod]        INT            NOT NULL,
    [HeadcountForecastID]     CHAR (22)      NOT NULL,
    [HeadcountForecastName]   NVARCHAR (100) NOT NULL,
    [ModifierUserID]          NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]       DATETIME       NULL,
    [ProcessCompletionLevel]  INT            NOT NULL,
    [SLCalibration]           VARCHAR (MAX)  NULL,
    [UsesNewSkillsetBehavior] TINYINT        NOT NULL,
    [Version]                 INT            NOT NULL,
    [VolumeForecastID]        CHAR (22)      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_HeadcountForecast] PRIMARY KEY CLUSTERED ([HeadcountForecastID] ASC)
);

