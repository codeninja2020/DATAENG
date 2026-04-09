CREATE TABLE [Genesys_dbo].[IO_VolumeForecast] (
    [Description]             NVARCHAR (2000) NULL,
    [ForecastScheduleEntryID] CHAR (22)       NOT NULL,
    [ForecastStatus]          INT             NOT NULL,
    [ForecastType]            INT             NOT NULL,
    [ModifierUserID]          NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]       DATETIME        NULL,
    [ProcessCompletionLevel]  INT             NOT NULL,
    [PureCloudID]             NVARCHAR (45)   NULL,
    [RouteGroupMap]           VARCHAR (MAX)   NULL,
    [Version]                 INT             NOT NULL,
    [VolumeForecastID]        CHAR (22)       NOT NULL,
    [VolumeForecastName]      NVARCHAR (100)  NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_VolumeForecast] PRIMARY KEY CLUSTERED ([VolumeForecastID] ASC)
);

