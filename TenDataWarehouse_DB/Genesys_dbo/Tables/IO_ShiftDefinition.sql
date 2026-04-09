CREATE TABLE [Genesys_dbo].[IO_ShiftDefinition] (
    [DesiredMaximumPaidTime]    INT            NOT NULL,
    [MaximumDays]               INT            NOT NULL,
    [MaximumPaidTime]           INT            NOT NULL,
    [MinimumInterShiftTime]     INT            NOT NULL,
    [MinimumPaidTime]           INT            NOT NULL,
    [ModifierUserID]            NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]         DATETIME       NULL,
    [ScheduleBidding]           TINYINT        NULL,
    [SchedulingUnitID]          CHAR (22)      NOT NULL,
    [ShiftDefinitionID]         CHAR (22)      NOT NULL,
    [ShiftDefinitionName]       NVARCHAR (100) NOT NULL,
    [UseDesiredMaximumPaidTime] TINYINT        NOT NULL,
    [UseMaximumDays]            TINYINT        NOT NULL,
    [UseMaximumPaidTime]        TINYINT        NOT NULL,
    [UseMinimumInterShiftTime]  TINYINT        NOT NULL,
    [UseMinimumPaidTime]        TINYINT        NOT NULL,
    [Version]                   INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ShiftDefinition] PRIMARY KEY CLUSTERED ([ShiftDefinitionID] ASC)
);

