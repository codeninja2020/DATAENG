CREATE TABLE [Django].[travel_hotels] (
    [id]                  INT             NOT NULL,
    [name]                NVARCHAR (4000) NULL,
    [ivector_connect_id]  NVARCHAR (4000) NULL,
    [latitude]            DECIMAL (9, 6)  NULL,
    [longitude]           DECIMAL (9, 6)  NULL,
    [star_rating]         NVARCHAR (4000) NULL,
    [location_id]         NVARCHAR (4000) NULL,
    [city]                NVARCHAR (4000) NULL,
    [country]             NVARCHAR (4000) NULL,
    [expedia_id]          INT             NULL,
    [benefit_collections] NVARCHAR (4000) NULL,
    [inserted_on]         DATETIME        NOT NULL,
    [processid]           VARCHAR (255)   NULL
);

