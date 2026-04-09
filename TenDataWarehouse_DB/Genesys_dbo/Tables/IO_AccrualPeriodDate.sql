CREATE TABLE [Genesys_dbo].[IO_AccrualPeriodDate] (
    [AccrualPeriod]       INT            NOT NULL,
    [AccrualPeriodDateID] CHAR (22)      NOT NULL,
    [FirstDate]           DATETIME       NOT NULL,
    [ModifierUserID]      NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]   DATETIME       NULL,
    [SchedulingUnitID]    CHAR (22)      NOT NULL,
    [SecondDate]          DATETIME       NULL,
    [Version]             INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AccrualPeriodDate] PRIMARY KEY CLUSTERED ([AccrualPeriodDateID] ASC)
);

