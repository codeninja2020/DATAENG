CREATE TABLE [TenMAID_US].[MemberInvoices_Staging] (
    [ActualPayDate]        DATETIME       NULL,
    [Comments]             NVARCHAR (400) NULL,
    [InsertedDateTime]     DATETIME       NULL,
    [InvoiceAmount]        MONEY          NULL,
    [IsPaymentTaken]       BIT            NULL,
    [MemberID]             INT            NULL,
    [MemberInvoiceID]      INT            NOT NULL,
    [MembershipFees]       MONEY          NULL,
    [PayableBy]            VARCHAR (50)   NULL,
    [PayableEach]          VARCHAR (50)   NULL,
    [WhenPaymentTaken]     DATETIME       NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_MemberInvoices_Staging] PRIMARY KEY CLUSTERED ([MemberInvoiceID] ASC)
);

