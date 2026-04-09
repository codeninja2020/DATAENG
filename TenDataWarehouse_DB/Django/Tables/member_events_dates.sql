CREATE TABLE [Django].[member_events_dates] (
    [id]             INT             NOT NULL,
    [event_id]       INT             NULL,
    [local_datetime] NVARCHAR (4000) NULL,
    [inserted_on]    DATETIME        NOT NULL,
    [processid]      VARCHAR (255)   NULL
);

