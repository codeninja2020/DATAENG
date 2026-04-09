CREATE TABLE [Genesys_dbo].[IO_NamedSchedule] (
    [Biddable]                TINYINT         NULL,
    [ForecastScheduleEntryID] CHAR (22)       NOT NULL,
    [HeadcountForecastID]     CHAR (22)       NULL,
    [IsEditPublish]           TINYINT         NOT NULL,
    [ModifierUserID]          NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]       DATETIME        NULL,
    [NamedScheduleID]         CHAR (22)       NOT NULL,
    [Published]               TINYINT         NOT NULL,
    [PublishedDateTimeUTC]    DATETIME        NULL,
    [PublishNotes]            NVARCHAR (2000) NULL,
    [ScheduleName]            NVARCHAR (100)  NOT NULL,
    [Version]                 INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_NamedSchedule] PRIMARY KEY CLUSTERED ([NamedScheduleID] ASC)
);

