CREATE TABLE [Genesys_dbo].[IO_DayClassOverride] (
    [DayClassificationID] CHAR (22)      NOT NULL,
    [DayClassOverrideID]  CHAR (22)      NOT NULL,
    [IntervalStart]       DATETIME       NOT NULL,
    [ModifierUserID]      NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]   DATETIME       NULL,
    [SchedulingUnitID]    CHAR (22)      NOT NULL,
    [Version]             INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_DayClassOverride] PRIMARY KEY CLUSTERED ([DayClassOverrideID] ASC)
);

