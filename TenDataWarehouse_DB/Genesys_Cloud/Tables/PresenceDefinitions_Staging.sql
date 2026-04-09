CREATE TABLE [Genesys_Cloud].[PresenceDefinitions_Staging] (
    [id]                   NVARCHAR (128) NOT NULL,
    [name]                 NVARCHAR (MAX) NULL,
    [systemPresence]       NVARCHAR (MAX) NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_dbo.PresenceDefinitions_Staging] PRIMARY KEY CLUSTERED ([id] ASC)
);

