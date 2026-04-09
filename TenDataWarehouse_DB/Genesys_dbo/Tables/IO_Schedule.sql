CREATE TABLE [Genesys_dbo].[IO_Schedule] (
    [AgentID]           CHAR (22)      NULL,
    [Biddable]          TINYINT        NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [NamedScheduleID]   CHAR (22)      NOT NULL,
    [PeriodScheduleID]  INT            NULL,
    [ScheduleID]        CHAR (22)      NOT NULL,
    [ShiftDefinitionID] CHAR (22)      NULL,
    [StartDateTimeUTC]  DATETIME       NOT NULL,
    [StopDateTimeUTC]   DATETIME       NOT NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_Schedule] PRIMARY KEY CLUSTERED ([ScheduleID] ASC)
);

