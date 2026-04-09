CREATE TABLE [Genesys_dbo].[IO_UtilizationSettings] (
    [InteractionType]       INT            NOT NULL,
    [MaximumAssignable]     TINYINT        NOT NULL,
    [ModifierUserID]        NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]     DATETIME       NULL,
    [PercentUtilization]    TINYINT        NOT NULL,
    [UtilizationSettingsID] CHAR (22)      NOT NULL,
    [Version]               INT            NOT NULL,
    [WorkgroupID]           CHAR (22)      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_UtilizationSettings] PRIMARY KEY CLUSTERED ([UtilizationSettingsID] ASC)
);

