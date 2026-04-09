CREATE TABLE [Django].[dining_restaurant_benefits] (
    [id]            INT             NOT NULL,
    [name]          NVARCHAR (4000) NULL,
    [benefit_code]  NVARCHAR (4000) NULL,
    [restaurant_id] INT             NULL,
    [inserted_on]   DATETIME        NOT NULL,
    [processid]     VARCHAR (255)   NULL
);

