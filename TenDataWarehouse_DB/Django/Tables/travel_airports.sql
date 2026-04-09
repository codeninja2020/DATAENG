CREATE TABLE [Django].[travel_airports] (
    [id]                 INT             NOT NULL,
    [name]               NVARCHAR (4000) NULL,
    [ivector_connect_id] NVARCHAR (4000) NULL,
    [iata_code]          NVARCHAR (4000) NULL,
    [location_id]        NVARCHAR (50)   NULL,
    [latitude]           DECIMAL (9, 6)  NULL,
    [longitude]          DECIMAL (9, 6)  NULL,
    [inserted_on]        DATETIME        NOT NULL,
    [processid]          VARCHAR (255)   NULL
);

