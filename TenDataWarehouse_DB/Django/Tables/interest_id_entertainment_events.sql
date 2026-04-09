CREATE TABLE [Django].[interest_id_entertainment_events] (
    [primary_interest_id] INT           NOT NULL,
    [inserted_on]         DATETIME      NULL,
    [processid]           VARCHAR (255) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_id]
    ON [Django].[interest_id_entertainment_events];

