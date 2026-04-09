CREATE TABLE [TenMAID_Global].[WarmTransfer] (
    [WarmTransferID] INT            NOT NULL,
    [Name]           NVARCHAR (150) NULL,
    [SupplierID]     INT            NULL,
    CONSTRAINT [PK_WarmTransfer] PRIMARY KEY CLUSTERED ([WarmTransferID] ASC)
);

