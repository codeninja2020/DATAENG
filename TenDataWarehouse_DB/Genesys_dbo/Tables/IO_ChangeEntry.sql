CREATE TABLE [Genesys_dbo].[IO_ChangeEntry] (
    [ChangeEntryID]           CHAR (22)      NOT NULL,
    [ChangeType]              INT            NOT NULL,
    [ObjectID]                CHAR (22)      NOT NULL,
    [ObjectModifierUserID]    NVARCHAR (100) NOT NULL,
    [ObjectModifyDateTimeUTC] DATETIME       NOT NULL,
    [ObjectType]              INT            NOT NULL,
    [ObjectVersion]           INT            NOT NULL,
    [ScopeID]                 CHAR (22)      NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ChangeEntry] PRIMARY KEY CLUSTERED ([ChangeEntryID] ASC)
);

