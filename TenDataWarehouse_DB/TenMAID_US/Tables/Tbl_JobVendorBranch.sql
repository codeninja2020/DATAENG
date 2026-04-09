CREATE TABLE [TenMAID_US].[Tbl_JobVendorBranch] (
    [BranchID] INT NULL,
    [Id]       INT NOT NULL,
    [JobID]    INT NOT NULL,
    [VendorID] INT NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_JobVendorBranch] PRIMARY KEY CLUSTERED ([Id] ASC)
);

