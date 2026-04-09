CREATE TABLE [Genesys_dbo].[IO_ShiftRotation] (
    [ModifierUserID]       NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]    DATETIME       NULL,
    [RotationStartDateUTC] DATETIME       NULL,
    [RotationStopDateUTC]  DATETIME       NULL,
    [SchedulingUnitID]     CHAR (22)      NOT NULL,
    [ShiftRotationID]      CHAR (22)      NOT NULL,
    [ShiftRotationName]    NVARCHAR (100) NOT NULL,
    [Version]              INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ShiftRotation] PRIMARY KEY CLUSTERED ([ShiftRotationID] ASC)
);

