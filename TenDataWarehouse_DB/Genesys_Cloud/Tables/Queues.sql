CREATE TABLE [Genesys_Cloud].[Queues] (
    [id]         NVARCHAR (128) NOT NULL,
    [name]       NVARCHAR (MAX) NULL,
    [InsertedOn] DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.Queues] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Queues] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

