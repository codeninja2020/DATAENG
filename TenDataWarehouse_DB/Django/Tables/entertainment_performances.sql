CREATE TABLE [Django].[entertainment_performances] (
    [id]                    INT             NOT NULL,
    [event_id]              INT             NULL,
    [venue_id]              INT             NULL,
    [start_local_date_time] NVARCHAR (4000) NULL,
    [ten_direct_vendor_id]  INT             NULL,
    [inserted_on]           DATETIME        NOT NULL,
    [processid]             VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_entertainment_performances_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

