CREATE TABLE [Genesys_Cloud].[Languages] (
    [id]         NVARCHAR (128) NOT NULL,
    [name]       NVARCHAR (MAX) NULL,
    [InsertedOn] DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.Languages] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Languages] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

