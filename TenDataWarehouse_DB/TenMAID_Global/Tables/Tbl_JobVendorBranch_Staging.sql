CREATE TABLE [TenMAID_Global].[Tbl_JobVendorBranch_Staging] (
    [BranchID]             INT          NULL,
    [Id]                   INT          NOT NULL,
    [JobID]                INT          NULL,
    [VendorID]             INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_JobVendorBranch_Staging] PRIMARY KEY CLUSTERED ([Id] ASC)
);

