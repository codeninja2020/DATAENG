CREATE TABLE [Genesys_dbo].[IO_Upgrade] (
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [UpgradeID]         CHAR (22)      NOT NULL,
    [UpgradeVersion]    INT            NOT NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_Upgrade] PRIMARY KEY CLUSTERED ([UpgradeID] ASC)
);

