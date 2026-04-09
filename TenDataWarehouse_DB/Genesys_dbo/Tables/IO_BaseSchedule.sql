CREATE TABLE [Genesys_dbo].[IO_BaseSchedule] (
    [ActivityBidding]           TINYINT        NOT NULL,
    [AgentID]                   CHAR (22)      NOT NULL,
    [BaseScheduleID]            CHAR (22)      NOT NULL,
    [EffectiveStartDateTimeUTC] DATETIME       NOT NULL,
    [EffectiveStopDateTimeUTC]  DATETIME       NULL,
    [ModifierUserID]            NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]         DATETIME       NULL,
    [ScheduleBidID]             CHAR (22)      NULL,
    [Version]                   INT            NOT NULL,
    [XData]                     NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_BaseSchedule] PRIMARY KEY CLUSTERED ([BaseScheduleID] ASC)
);

