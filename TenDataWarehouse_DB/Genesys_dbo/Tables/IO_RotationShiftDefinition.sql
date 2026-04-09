CREATE TABLE [Genesys_dbo].[IO_RotationShiftDefinition] (
    [ModifierUserID]            NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]         DATETIME       NULL,
    [RotationIndex]             INT            NOT NULL,
    [RotationShiftDefinitionID] CHAR (22)      NOT NULL,
    [ShiftDefinitionID]         CHAR (22)      NOT NULL,
    [ShiftRotationID]           CHAR (22)      NOT NULL,
    [Version]                   INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_RotationShiftDefinition] PRIMARY KEY CLUSTERED ([RotationShiftDefinitionID] ASC)
);

