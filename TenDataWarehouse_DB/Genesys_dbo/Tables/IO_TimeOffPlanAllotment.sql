CREATE TABLE [Genesys_dbo].[IO_TimeOffPlanAllotment] (
    [AllotmentDayOffset]     INT            NOT NULL,
    [AllottedHours]          NUMERIC (18)   NOT NULL,
    [AllottedHoursCap]       NUMERIC (18)   NULL,
    [CoverageGroupID]        CHAR (22)      NOT NULL,
    [IsBlackedOut]           TINYINT        NOT NULL,
    [ModifierUserID]         NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]      DATETIME       NULL,
    [PredictedStaffHours]    NUMERIC (18)   NULL,
    [RequiredStaffHours]     NUMERIC (18)   NULL,
    [TimeOffPlanAllotmentID] CHAR (22)      NOT NULL,
    [TimeOffPlanID]          CHAR (22)      NOT NULL,
    [Version]                INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_TimeOffPlanAllotment] PRIMARY KEY CLUSTERED ([TimeOffPlanAllotmentID] ASC)
);

