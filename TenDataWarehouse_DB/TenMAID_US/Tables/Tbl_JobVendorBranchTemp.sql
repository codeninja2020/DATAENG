CREATE TABLE [TenMAID_US].[Tbl_JobVendorBranchTemp] (
    [BranchID]     INT            NULL,
    [JobVendorsID] INT            NOT NULL,
    [TempJobID]    NVARCHAR (100) NOT NULL,
    [VendorID]     INT            NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_JobVendorBranchTemp] PRIMARY KEY CLUSTERED ([JobVendorsID] ASC)
);

