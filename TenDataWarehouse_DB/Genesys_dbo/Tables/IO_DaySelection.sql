CREATE TABLE [Genesys_dbo].[IO_DaySelection] (
    [DaySelectionID]    CHAR (22)      NOT NULL,
    [ForecastDateUTC]   DATETIME       NOT NULL,
    [HistoryDate]       DATETIME       NOT NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [UTCMinutesOffset]  INT            NOT NULL,
    [Version]           INT            NOT NULL,
    [VolumeForecastID]  CHAR (22)      NOT NULL,
    [Weight]            INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_DaySelection] PRIMARY KEY CLUSTERED ([DaySelectionID] ASC)
);

