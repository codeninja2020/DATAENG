CREATE TABLE [Django].[entertainment_delivery_methods] (
    [id]             INT             NOT NULL,
    [name]           NVARCHAR (4000) NULL,
    [price_currency] NVARCHAR (4000) NULL,
    [provider]       NVARCHAR (4000) NULL,
    [inserted_on]    DATETIME        NOT NULL,
    [processid]      VARCHAR (255)   NULL
);

