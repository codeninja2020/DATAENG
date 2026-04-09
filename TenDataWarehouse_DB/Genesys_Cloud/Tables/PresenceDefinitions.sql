CREATE TABLE [Genesys_Cloud].[PresenceDefinitions] (
    [id]             NVARCHAR (128) NOT NULL,
    [name]           NVARCHAR (MAX) NULL,
    [systemPresence] NVARCHAR (MAX) NULL,
    [InsertedOn]     DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.PresenceDefinitions] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[PresenceDefinitions] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

