
CREATE TABLE [Django].[dining_restaurants] (
    [id]              INT             NOT NULL,
    [name]            NVARCHAR (4000) NULL,
    [latitude]        NVARCHAR (4000) NULL,
    [longitude]       NVARCHAR (4000) NULL,
    [city]            NVARCHAR (4000) NULL,
    [postcode]        NVARCHAR (4000) NULL,
    [country]         NVARCHAR (4000) NULL,
    [cuisine]         NVARCHAR (4000) NULL,
    [location_id]     NVARCHAR (64)   NULL,
    [price_indicator] NVARCHAR (4000) NULL,
    [rating]          NVARCHAR (4000) NULL,
    [website]         NVARCHAR (4000) NULL,
    [vendor_id]       INT             NULL,
    [tags]            NVARCHAR (4000) NULL,
    [inserted_on]     DATETIME        NOT NULL,
    [processid]       VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_dining_restaurants_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

