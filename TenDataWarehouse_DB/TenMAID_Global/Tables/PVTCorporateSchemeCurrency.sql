CREATE TABLE [TenMAID_Global].[PVTCorporateSchemeCurrency] (
    [CurrencyID]     INT           NULL,
    [MerchantID]     NVARCHAR (15) NULL,
    [PvtCorSchCurID] INT           NOT NULL,
    [SchemeID]       INT           NULL,
    CONSTRAINT [PK_TenMAID_Global_PVTCorporateSchemeCurrency] PRIMARY KEY CLUSTERED ([PvtCorSchCurID] ASC)
);

