CREATE TABLE [TenMAID_US].[PVTCorporateSchemeCurrency_Staging] (
    [CurrencyID]           INT           NULL,
    [MerchantID]           NVARCHAR (15) NULL,
    [PvtCorSchCurID]       INT           NOT NULL,
    [SchemeID]             INT           NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_PVTCorporateSchemeCurrency_Staging] PRIMARY KEY CLUSTERED ([PvtCorSchCurID] ASC)
);

