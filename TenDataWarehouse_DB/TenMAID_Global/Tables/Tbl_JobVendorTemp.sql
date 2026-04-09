CREATE TABLE [TenMAID_Global].[Tbl_JobVendorTemp] (
    [BranchID]     INT            NULL,
    [JobVendorsID] INT            NOT NULL,
    [TempJobID]    NVARCHAR (100) NOT NULL,
    [VendorID]     INT            NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_JobVendorTemp] PRIMARY KEY CLUSTERED ([JobVendorsID] ASC)
);

