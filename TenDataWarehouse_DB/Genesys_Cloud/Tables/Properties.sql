CREATE TABLE [Genesys_Cloud].[Properties] (
    [RowId]         BIGINT         NOT NULL,
    [propertyType]  NVARCHAR (MAX) NULL,
    [property]      NVARCHAR (MAX) NULL,
    [value]         NVARCHAR (MAX) NULL,
    [Segment_RowId] BIGINT         NULL,
    [InsertedOn]    DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.Properties] PRIMARY KEY CLUSTERED ([RowId] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Properties] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

