CREATE TABLE [TenMAID_Global].[InvoiceFrequency_Staging] (
    [InvoiceFrequencyID]   INT           NOT NULL,
    [Name]                 NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_InvoiceFrequency_Staging] PRIMARY KEY CLUSTERED ([InvoiceFrequencyID] ASC)
);

