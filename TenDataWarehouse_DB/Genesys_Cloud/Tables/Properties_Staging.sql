CREATE TABLE [Genesys_Cloud].[Properties_Staging] (
    [RowId]                BIGINT         NOT NULL,
    [propertyType]         NVARCHAR (MAX) NULL,
    [property]             NVARCHAR (MAX) NULL,
    [value]                NVARCHAR (MAX) NULL,
    [Segment_RowId]        BIGINT         NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_Genesys_Cloud.Properties_Staging] PRIMARY KEY CLUSTERED ([RowId] ASC)
);

