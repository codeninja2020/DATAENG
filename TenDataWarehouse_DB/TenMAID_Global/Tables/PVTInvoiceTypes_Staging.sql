CREATE TABLE [TenMAID_Global].[PVTInvoiceTypes_Staging] (
    [Description]          NVARCHAR (100) NULL,
    [PvtInvTypID]          INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_PVTInvoiceTypes_Staging] PRIMARY KEY CLUSTERED ([PvtInvTypID] ASC)
);

