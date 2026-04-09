CREATE TABLE [Django].[tags] (
    [id]                     INT             NOT NULL,
    [name]                   NVARCHAR (4000) NULL,
    [tag_group]              NVARCHAR (4000) NULL,
    [articles_module]        NVARCHAR (4000) NULL,
    [travel_module]          NVARCHAR (4000) NULL,
    [dining_module]          NVARCHAR (4000) NULL,
    [entertainment_module]   NVARCHAR (4000) NULL,
    [member_benefits_module] NVARCHAR (4000) NULL,
    [member_events_module]   NVARCHAR (4000) NULL,
    [inserted_on]            DATETIME        NOT NULL,
    [processid]              VARCHAR (255)   NULL,
    [interest_type]          NVARCHAR (4000) NULL,
    [is_interest]            NVARCHAR (5)    NULL
);

