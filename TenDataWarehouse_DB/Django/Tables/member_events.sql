CREATE TABLE [Django].[member_events] (
    [id]                          INT             NOT NULL,
    [name]                        NVARCHAR (4000) NULL,
    [latitude]                    DECIMAL (9, 6)  NULL,
    [longitude]                   DECIMAL (9, 6)  NULL,
    [city]                        NVARCHAR (4000) NULL,
    [country]                     NVARCHAR (4000) NULL,
    [postcode]                    NVARCHAR (4000) NULL,
    [type]                        NVARCHAR (4000) NULL,
    [adult_ticket_price]          MONEY           NULL,
    [adult_ticket_price_currency] NVARCHAR (4000) NULL,
    [child_ticket_price]          MONEY           NULL,
    [child_ticket_price_currency] NVARCHAR (4000) NULL,
    [chosen_tags]                 NVARCHAR (4000) NULL,
    [sites]                       NVARCHAR (4000) NULL,
    [supplier]                    NVARCHAR (4000) NULL,
    [vendor_id]                   INT             NULL,
    [inserted_on]                 DATETIME        NOT NULL,
    [processid]                   VARCHAR (255)   NULL,
    CONSTRAINT [PK_Django_member_events_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

