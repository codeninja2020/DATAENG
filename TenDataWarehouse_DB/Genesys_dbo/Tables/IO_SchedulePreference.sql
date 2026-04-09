CREATE TABLE [Genesys_dbo].[IO_SchedulePreference] (
    [ActivityTypeID]             CHAR (22)      NULL,
    [Length]                     INT            NOT NULL,
    [ModifierUserID]             NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]          DATETIME       NULL,
    [Rating]                     SMALLINT       NOT NULL,
    [SchedulePreferenceID]       CHAR (22)      NOT NULL,
    [SchedulePreferencesEntryID] CHAR (22)      NOT NULL,
    [StartDateTimeUTC]           DATETIME       NOT NULL,
    [Version]                    INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_SchedulePreference] PRIMARY KEY CLUSTERED ([SchedulePreferenceID] ASC)
);

