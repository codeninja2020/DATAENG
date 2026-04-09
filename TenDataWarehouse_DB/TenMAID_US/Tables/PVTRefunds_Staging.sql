CREATE TABLE [TenMAID_US].[PVTRefunds_Staging] (
    [Amount]                  MONEY          NULL,
    [AmountInGBP]             MONEY          NULL,
    [AmountInRequestCurrency] MONEY          NULL,
    [CreatedBy]               INT            NULL,
    [CurrencyID]              INT            NULL,
    [DateCreated]             DATETIME       NULL,
    [DateRefunded]            DATETIME       NULL,
    [DateUpdated]             DATETIME       NULL,
    [Description]             NVARCHAR (250) NULL,
    [IsRefundSent]            BIT            NULL,
    [JobID]                   INT            NULL,
    [MemberID]                INT            NULL,
    [PvtRefID]                INT            NOT NULL,
    [PvtRefMetID]             INT            NULL,
    [SupInvoiceID]            INT            NULL,
    [SupplierID]              INT            NULL,
    [UpdatedBy]               INT            NULL,
    [VendorID]                INT            NULL,
    [SYS_CHANGE_OPERATION]    NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]      BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_PVTRefunds_Staging] PRIMARY KEY CLUSTERED ([PvtRefID] ASC)
);

