CREATE TABLE [Django].[entertainment_events] (
    [id]                     INT             NOT NULL,
    [name]                   NVARCHAR (4000) NULL,
    [category]               NVARCHAR (4000) NULL,
    [number_of_performances] NVARCHAR (4000) NULL,
    [popularity]             NVARCHAR (4000) NULL,
    [currency]               NVARCHAR (4000) NULL,
    [active]                 NVARCHAR (4000) NULL,
    [created]                DATETIME2 (0)   NULL,
    [chosen_tags]            NVARCHAR (4000) NULL,
    [inserted_on]            DATETIME        NOT NULL,
    [processid]              VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_entertainment_events_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

