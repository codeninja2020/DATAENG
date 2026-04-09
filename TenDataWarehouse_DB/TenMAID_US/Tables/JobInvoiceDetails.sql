CREATE TABLE [TenMAID_US].[JobInvoiceDetails] (
    [CurrencyID]                      INT            NOT NULL,
    [Department]                      INT            NULL,
    [InvoiceCost]                     MONEY          NOT NULL,
    [InvoiceCostInOtherCurrency]      MONEY          NULL,
    [InvoiceTotalCost]                MONEY          NOT NULL,
    [InvoiceTotalCostInOtherCurrency] MONEY          NULL,
    [InvoiceVAT]                      FLOAT (53)     NOT NULL,
    [InvoiceVATInOtherCurrency]       FLOAT (53)     NULL,
    [InvoiceVATPercentage]            FLOAT (53)     NOT NULL,
    [JobBookingDate]                  DATETIME       NULL,
    [JobCommission]                   MONEY          NULL,
    [JobCost]                         MONEY          NULL,
    [JobCurrencyID]                   INT            NULL,
    [JobID]                           INT            NOT NULL,
    [JobInvoiceDetailID]              INT            NOT NULL,
    [JobInvoiceID]                    INT            NOT NULL,
    [JobReference]                    NVARCHAR (250) NULL,
    [MemberID]                        INT            NOT NULL,
    [SupplierInvoiceItemID]           INT            NULL,
    CONSTRAINT [PK_TenMAID_US_JobInvoiceDetails] PRIMARY KEY CLUSTERED ([JobInvoiceDetailID] ASC)
);

