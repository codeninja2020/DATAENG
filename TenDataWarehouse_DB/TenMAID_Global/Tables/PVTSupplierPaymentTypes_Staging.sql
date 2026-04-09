CREATE TABLE [TenMAID_Global].[PVTSupplierPaymentTypes_Staging] (
    [Description]          NVARCHAR (50) NULL,
    [PvtSupPayTypID]       INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_PVTSupplierPaymentTypes_Staging] PRIMARY KEY CLUSTERED ([PvtSupPayTypID] ASC)
);

