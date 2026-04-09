CREATE TABLE [TenMAID_Global].[MemberInvoices] (
    [ActualPayDate]    DATETIME       NULL,
    [Comments]         NVARCHAR (400) NULL,
    [InsertedDateTime] DATETIME       NULL,
    [InvoiceAmount]    MONEY          NULL,
    [IsPaymentTaken]   BIT            NULL,
    [MemberID]         INT            NOT NULL,
    [MemberInvoiceID]  INT            NOT NULL,
    [MembershipFees]   MONEY          NULL,
    [PayableBy]        VARCHAR (50)   NULL,
    [PayableEach]      VARCHAR (50)   NULL,
    [WhenPaymentTaken] DATETIME       NULL,
    CONSTRAINT [PK_TenMAID_Global_MemberInvoices] PRIMARY KEY CLUSTERED ([MemberInvoiceID] ASC)
);

