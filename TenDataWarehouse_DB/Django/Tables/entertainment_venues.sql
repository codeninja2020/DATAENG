CREATE TABLE [Django].[entertainment_venues] (
    [id]           INT             NOT NULL,
    [name]         NVARCHAR (4000) NULL,
    [longitude]    DECIMAL (9, 6)  NULL,
    [latitude]     DECIMAL (9, 6)  NULL,
    [country]      NVARCHAR (4000) NULL,
    [postcode]     NVARCHAR (4000) NULL,
    [location_id]  NVARCHAR (36)   NULL,
    [see_venue_id] INT             NULL,
    [inserted_on]  DATETIME        NOT NULL,
    [processid]    VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_entertainment_venues_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

