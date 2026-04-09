CREATE TABLE [Genesys_dbo].[IO_ForecastScheduleEntry] (
    [EntryName]               NVARCHAR (100) NOT NULL,
    [ForecastScheduleEntryID] CHAR (22)      NOT NULL,
    [ModifierUserID]          NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]       DATETIME       NULL,
    [ProcessCompletionLevel]  INT            NOT NULL,
    [SchedulingUnitID]        CHAR (22)      NOT NULL,
    [StartDateUTC]            DATETIME       NOT NULL,
    [StopDateUTC]             DATETIME       NOT NULL,
    [TimeZoneID]              NVARCHAR (100) NULL,
    [Version]                 INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ForecastScheduleEntry] PRIMARY KEY CLUSTERED ([ForecastScheduleEntryID] ASC)
);

