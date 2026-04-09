CREATE TABLE [Django].[member_events_memberevent_tags] (
    [id]             INT           NOT NULL,
    [memberevent_id] INT           NULL,
    [tag_id]         INT           NULL,
    [inserted_on]    DATETIME      NULL,
    [processid]      VARCHAR (255) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_id]
    ON [Django].[member_events_memberevent_tags];

