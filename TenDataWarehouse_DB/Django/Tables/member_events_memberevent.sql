CREATE TABLE [Django].[member_events_memberevent] (
    [id]                  INT            NOT NULL,
    [name]                NVARCHAR (255) NULL,
    [type]                NVARCHAR (255) NULL,
    [supplier]            NVARCHAR (255) NULL,
    [primary_interest_id] INT            NULL,
    [inserted_on]         DATETIME       NULL,
    [processid]           VARCHAR (255)  NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_id]
    ON [Django].[member_events_memberevent];

