CREATE TABLE [Genesys_dbo].[IO_ScheduleInterval] (
    [ActivityCodeID]     CHAR (22)       NULL,
    [ActivityID]         CHAR (22)       NULL,
    [ActivityTypeID]     CHAR (22)       NOT NULL,
    [ContiguousTime]     TINYINT         NULL,
    [Description]        NVARCHAR (2000) NULL,
    [IsActual]           TINYINT         NULL,
    [IsLoggedIn]         TINYINT         NULL,
    [IsPlanned]          TINYINT         NULL,
    [ModifierUserID]     NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]  DATETIME        NULL,
    [PaidTime]           TINYINT         NULL,
    [ScheduleID]         CHAR (22)       NOT NULL,
    [ScheduleIntervalID] CHAR (22)       NOT NULL,
    [StartOffset]        INT             NOT NULL,
    [StopOffset]         INT             NOT NULL,
    [Version]            INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ScheduleInterval] PRIMARY KEY CLUSTERED ([ScheduleIntervalID] ASC)
);

