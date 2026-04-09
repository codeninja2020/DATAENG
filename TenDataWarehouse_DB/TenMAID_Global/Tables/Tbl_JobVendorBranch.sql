CREATE TABLE [TenMAID_Global].[Tbl_JobVendorBranch] (
    [BranchID] INT NULL,
    [Id]       INT NOT NULL,
    [JobID]    INT NOT NULL,
    [VendorID] INT NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_JobVendorBranch] PRIMARY KEY CLUSTERED ([Id] ASC)
);

