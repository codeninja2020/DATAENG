CREATE TABLE [TenMAID_Global].[Offices_Staging] (
    [AccountNo]            NVARCHAR (150) NULL,
    [BranchCode]           NVARCHAR (150) NULL,
    [Description]          NVARCHAR (200) NULL,
    [Email]                NVARCHAR (150) NULL,
    [Fax]                  NVARCHAR (50)  NULL,
    [IBAN]                 NVARCHAR (150) NULL,
    [IsOfficeInvoicing]    BIT            NULL,
    [Name]                 NVARCHAR (50)  NULL,
    [OfficeID]             INT            NOT NULL,
    [Phone]                NVARCHAR (50)  NULL,
    [SWIFTCode]            NVARCHAR (150) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Offices_Staging] PRIMARY KEY CLUSTERED ([OfficeID] ASC)
);

