CREATE TABLE [Genesys_dbo].[IO_AdvancedConfig] (
    [AdvancedConfigID]  CHAR (22)      NOT NULL,
    [ConfigKey]         NVARCHAR (100) NOT NULL,
    [ConfigValue]       NVARCHAR (MAX) NOT NULL,
    [IsConfigurable]    TINYINT        NOT NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [SchedulingUnitID]  CHAR (22)      NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AdvancedConfig] PRIMARY KEY CLUSTERED ([AdvancedConfigID] ASC)
);

