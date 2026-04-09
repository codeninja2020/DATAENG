CREATE TABLE [preference].[preference_product_reference] (
    [ProductReferenceID] INT             NOT NULL,
    [ProductID]          INT             NULL,
    [ProductType]        NVARCHAR (4000) NULL,
    [Rating]             INT             NULL,
    [Status]             NVARCHAR (5)    NULL,
    [inserted_on]        DATETIME        NULL,
    [processid]          VARCHAR (255)   NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_ProductReferenceID]
    ON [preference].[preference_product_reference];

