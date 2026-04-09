CREATE TABLE [Django].[travel_airport_groups] (
    [id]                 INT             NOT NULL,
    [name]               NVARCHAR (4000) NULL,
    [ivector_connect_id] INT             NULL,
    [airports]           NVARCHAR (4000) NULL,
    [inserted_on]        DATETIME        NOT NULL,
    [processid]          VARCHAR (255)   NULL
);

