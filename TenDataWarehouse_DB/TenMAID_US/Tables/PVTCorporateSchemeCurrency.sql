CREATE TABLE [TenMAID_US].[PVTCorporateSchemeCurrency] (
    [CurrencyID]     INT           NULL,
    [MerchantID]     NVARCHAR (15) NULL,
    [PvtCorSchCurID] INT           NOT NULL,
    [SchemeID]       INT           NULL,
    CONSTRAINT [PK_TenMAID_US_PVTCorporateSchemeCurrency] PRIMARY KEY CLUSTERED ([PvtCorSchCurID] ASC)
);

