CREATE TABLE [Django].[entertainment_artists] (
    [id]            INT             NOT NULL,
    [name]          NVARCHAR (4000) NULL,
    [see_artist_id] NVARCHAR (64)   NULL,
    [created_at]    DATETIME2 (0)   NULL,
    [inserted_on]   DATETIME        NOT NULL,
    [processid]     VARCHAR (255)   NULL
);

