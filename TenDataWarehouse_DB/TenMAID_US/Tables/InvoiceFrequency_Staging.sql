CREATE TABLE [TenMAID_US].[InvoiceFrequency_Staging] (
    [InvoiceFrequencyID]   INT           NOT NULL,
    [Name]                 NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_InvoiceFrequency_Staging] PRIMARY KEY CLUSTERED ([InvoiceFrequencyID] ASC)
);

