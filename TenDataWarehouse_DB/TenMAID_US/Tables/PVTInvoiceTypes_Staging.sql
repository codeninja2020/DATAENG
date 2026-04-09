CREATE TABLE [TenMAID_US].[PVTInvoiceTypes_Staging] (
    [Description]          NVARCHAR (100) NULL,
    [PvtInvTypID]          INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_PVTInvoiceTypes_Staging] PRIMARY KEY CLUSTERED ([PvtInvTypID] ASC)
);

