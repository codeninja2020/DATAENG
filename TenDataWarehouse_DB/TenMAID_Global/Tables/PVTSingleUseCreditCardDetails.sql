CREATE TABLE [TenMAID_Global].[PVTSingleUseCreditCardDetails] (
    [Amount]            MONEY    NULL,
    [CreatedBy]         INT      NULL,
    [CurrencyID]        INT      NULL,
    [DateCreated]       DATETIME NULL,
    [DateUpdated]       DATETIME NULL,
    [ExpiryDate]        DATETIME NULL,
    [PvtSinUseCreCarID] INT      NOT NULL,
    [PvtSupPayID]       INT      NULL,
    [UpdatedBy]         INT      NULL,
    CONSTRAINT [PK_TenMAID_Global_PVTSingleUseCreditCardDetails] PRIMARY KEY CLUSTERED ([PvtSinUseCreCarID] ASC)
);

