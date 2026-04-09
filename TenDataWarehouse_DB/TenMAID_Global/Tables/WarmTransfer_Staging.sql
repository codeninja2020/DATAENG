CREATE TABLE [TenMAID_Global].[WarmTransfer_Staging] (
    [WarmTransferID]       INT            NOT NULL,
    [Name]                 NVARCHAR (150) NULL,
    [SupplierID]           INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_WarmTransfer_Staging] PRIMARY KEY CLUSTERED ([WarmTransferID] ASC)
);

