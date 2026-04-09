CREATE TABLE [Django].[entertainment_ticket_types] (
    [id]                  INT             NOT NULL,
    [performance_id]      INT             NULL,
    [see_offer_id]        NVARCHAR (40)   NULL,
    [see_price_id]        NVARCHAR (40)   NULL,
    [price]               DECIMAL (20, 3) NULL,
    [price_currency]      NVARCHAR (4000) NULL,
    [face_price]          DECIMAL (20, 3) NULL,
    [face_price_currency] NVARCHAR (4000) NULL,
    [inserted_on]         DATETIME        NOT NULL,
    [processid]           VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_entertainment_ticket_types_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

