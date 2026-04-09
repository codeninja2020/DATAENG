CREATE TABLE [Django].[member_benefits] (
    [id]                          INT                NOT NULL,
    [name]                        NVARCHAR (4000)    NULL,
    [available_from]              DATETIMEOFFSET (7) NULL,
    [available_until]             DATETIMEOFFSET (7) NULL,
    [brand_id]                    INT                NULL,
    [location_id]                 NVARCHAR (50)      NULL,
    [status]                      NVARCHAR (4000)    NULL,
    [url_redemption]              NVARCHAR (4000)    NULL,
    [online_redemption_code]      NVARCHAR (4000)    NULL,
    [in_store_redemption]         NVARCHAR (4000)    NULL,
    [has_redemption_phone_number] NVARCHAR (4000)    NULL,
    [phone_number]                NVARCHAR (4000)    NULL,
    [chosen_tags]                 NVARCHAR (MAX)     NULL,
    [sites]                       NVARCHAR (MAX)     NULL,
    [inserted_on]                 DATETIME           NOT NULL,
    [processid]                   VARCHAR (255)      NULL,
    [ten_maid_offer_id]           VARCHAR (4000)     NULL,
    [rating]                      INT                NULL,
    [alternate_rating]            INT                NULL,
    CONSTRAINT [PK_Django_member_benefits_ID] PRIMARY KEY CLUSTERED ([id] ASC)
);

