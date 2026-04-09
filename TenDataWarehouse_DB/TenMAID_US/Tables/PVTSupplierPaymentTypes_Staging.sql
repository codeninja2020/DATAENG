CREATE TABLE [TenMAID_US].[PVTSupplierPaymentTypes_Staging] (
    [Description]          NVARCHAR (50) NULL,
    [PvtSupPayTypID]       INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_PVTSupplierPaymentTypes_Staging] PRIMARY KEY CLUSTERED ([PvtSupPayTypID] ASC)
);

