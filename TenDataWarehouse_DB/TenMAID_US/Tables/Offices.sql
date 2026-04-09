CREATE TABLE [TenMAID_US].[Offices] (
    [AccountNo]         NVARCHAR (150) NULL,
    [BranchCode]        NVARCHAR (150) NULL,
    [Description]       NVARCHAR (200) NOT NULL,
    [Email]             NVARCHAR (150) NULL,
    [Fax]               NVARCHAR (50)  NULL,
    [IBAN]              NVARCHAR (150) NULL,
    [IsOfficeInvoicing] BIT            NULL,
    [Name]              NVARCHAR (50)  NULL,
    [OfficeID]          INT            NOT NULL,
    [Phone]             NVARCHAR (50)  NULL,
    [SWIFTCode]         NVARCHAR (150) NULL,
    CONSTRAINT [PK_TenMAID_US_Offices] PRIMARY KEY CLUSTERED ([OfficeID] ASC)
);

