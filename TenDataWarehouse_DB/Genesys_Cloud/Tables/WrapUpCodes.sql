CREATE TABLE [Genesys_Cloud].[WrapUpCodes] (
    [id]         NVARCHAR (128) NOT NULL,
    [name]       NVARCHAR (MAX) NULL,
    [InsertedOn] DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.WrapUpCodes] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[WrapUpCodes] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

