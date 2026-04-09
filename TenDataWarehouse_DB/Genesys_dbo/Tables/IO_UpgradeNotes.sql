CREATE TABLE [Genesys_dbo].[IO_UpgradeNotes] (
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [Notes]             NVARCHAR (MAX) NOT NULL,
    [UpgradeNotesID]    CHAR (22)      NOT NULL,
    [UpgradeNotesLevel] INT            NOT NULL,
    [UpgradeVersion]    INT            NOT NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_UpgradeNotes] PRIMARY KEY CLUSTERED ([UpgradeNotesID] ASC)
);

