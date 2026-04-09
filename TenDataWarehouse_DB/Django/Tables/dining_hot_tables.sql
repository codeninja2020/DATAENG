CREATE TABLE [Django].[dining_hot_tables] (
    [id]                    INT             NOT NULL,
    [name]                  NVARCHAR (4000) NULL,
    [id2]                   NVARCHAR (4000) NULL,
    [number_of_seats]       INT             NULL,
    [available_at_datetime] DATETIME        NULL,
    [inserted_on]           DATETIME        NOT NULL,
    [processid]             VARCHAR (255)   NULL
);

