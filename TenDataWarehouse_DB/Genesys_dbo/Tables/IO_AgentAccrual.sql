CREATE TABLE [Genesys_dbo].[IO_AgentAccrual] (
    [AccrualPeriodOverride]    INT            NULL,
    [AccrualPlanID]            CHAR (22)      NOT NULL,
    [AccrualRateHoursOverride] NUMERIC (18)   NULL,
    [AccruedHours]             NUMERIC (18)   NOT NULL,
    [AgentAccrualID]           CHAR (22)      NOT NULL,
    [AgentID]                  CHAR (22)      NOT NULL,
    [MaxAccruedHoursCap]       NUMERIC (18)   NULL,
    [ModifierUserID]           NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]        DATETIME       NULL,
    [Version]                  INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AgentAccrual] PRIMARY KEY CLUSTERED ([AgentAccrualID] ASC)
);

