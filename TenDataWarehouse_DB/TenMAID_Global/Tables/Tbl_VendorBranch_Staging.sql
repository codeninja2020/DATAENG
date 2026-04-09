CREATE TABLE [TenMAID_Global].[Tbl_VendorBranch_Staging] (
    [BranchId]             INT          NOT NULL,
    [VendorId]             INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_VendorBranch_Staging] PRIMARY KEY CLUSTERED ([BranchId] ASC)
);

