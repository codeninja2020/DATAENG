CREATE TABLE [TenMAID_US].[InvoiceCurrency] (
    [CrditDebit]      BIT           NULL,
    [CurrencyValue]   FLOAT (53)    NULL,
    [Details]         VARCHAR (50)  NULL,
    [ImageName]       NVARCHAR (50) NULL,
    [IsDefault]       BIT           NULL,
    [ISO_CurrencyID]  INT           NOT NULL,
    [LastUpdated]     DATETIME      NULL,
    [MemberPayment]   BIT           NULL,
    [Name]            NVARCHAR (50) NULL,
    [OrderBy]         INT           NULL,
    [Quote]           BIT           NULL,
    [ShortName]       NVARCHAR (50) NULL,
    [SingleUser]      BIT           NULL,
    [SupplierPayment] BIT           NULL,
    [Symbol]          NVARCHAR (6)  NULL,
    CONSTRAINT [PK_TenMAID_US_InvoiceCurrency] PRIMARY KEY CLUSTERED ([ISO_CurrencyID] ASC)
);

