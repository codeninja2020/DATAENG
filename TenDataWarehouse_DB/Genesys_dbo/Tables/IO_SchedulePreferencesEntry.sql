CREATE TABLE [Genesys_dbo].[IO_SchedulePreferencesEntry] (
    [AgentID]                    CHAR (22)      NOT NULL,
    [EntryName]                  NVARCHAR (100) NOT NULL,
    [IsDefault]                  TINYINT        NOT NULL,
    [ModifierUserID]             NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]          DATETIME       NULL,
    [SchedulePreferencesEntryID] CHAR (22)      NOT NULL,
    [StartDateTimeUTC]           DATETIME       NULL,
    [StopDateTimeUTC]            DATETIME       NULL,
    [Version]                    INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_SchedulePreferencesEntry] PRIMARY KEY CLUSTERED ([SchedulePreferencesEntryID] ASC)
);

