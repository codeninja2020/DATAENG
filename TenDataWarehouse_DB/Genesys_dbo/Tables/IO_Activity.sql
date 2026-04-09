CREATE TABLE [Genesys_dbo].[IO_Activity] (
    [ActivityCodeID]       CHAR (22)       NULL,
    [ActivityID]           CHAR (22)       NOT NULL,
    [ActivityTypeID]       CHAR (22)       NOT NULL,
    [AgentID]              CHAR (22)       NULL,
    [AttendanceReqType]    INT             NULL,
    [ContiguousTime]       TINYINT         NOT NULL,
    [DailyConstraintsID]   CHAR (22)       NULL,
    [Description]          NVARCHAR (2000) NULL,
    [EarliestStartTimeUTC] DATETIME        NOT NULL,
    [IsPlanned]            TINYINT         NULL,
    [LatestStartTimeUTC]   DATETIME        NOT NULL,
    [Length]               INT             NOT NULL,
    [ModifierUserID]       NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]    DATETIME        NULL,
    [PaidTime]             TINYINT         NOT NULL,
    [RelativeTimes]        TINYINT         NOT NULL,
    [ReplaceShiftActivity] TINYINT         NOT NULL,
    [StartTimeIncrement]   INT             NOT NULL,
    [TimeOffRequestID]     CHAR (22)       NULL,
    [Version]              INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_Activity] PRIMARY KEY CLUSTERED ([ActivityID] ASC)
);

