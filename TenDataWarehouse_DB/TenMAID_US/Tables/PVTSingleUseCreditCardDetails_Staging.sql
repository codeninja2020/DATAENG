CREATE TABLE [TenMAID_US].[PVTSingleUseCreditCardDetails_Staging] (
    [Amount]               MONEY        NULL,
    [CreatedBy]            INT          NULL,
    [CurrencyID]           INT          NULL,
    [DateCreated]          DATETIME     NULL,
    [DateUpdated]          DATETIME     NULL,
    [ExpiryDate]           DATETIME     NULL,
    [PvtSinUseCreCarID]    INT          NOT NULL,
    [PvtSupPayID]          INT          NULL,
    [UpdatedBy]            INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_PVTSingleUseCreditCardDetails_Staging] PRIMARY KEY CLUSTERED ([PvtSinUseCreCarID] ASC)
);

