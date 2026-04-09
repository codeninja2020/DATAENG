CREATE TABLE [Django].[entertainment_event_tags] (
    [id]          INT           NOT NULL,
    [event_id]    INT           NULL,
    [tag_id]      INT           NULL,
    [inserted_on] DATETIME      NULL,
    [processid]   VARCHAR (255) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_id]
    ON [Django].[entertainment_event_tags];

