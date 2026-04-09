CREATE TABLE [TenMAID_Global].[Tbl_JobVendorTemp_Staging] (
    [BranchID]             INT            NULL,
    [JobVendorsID]         INT            NOT NULL,
    [TempJobID]            NVARCHAR (100) NULL,
    [VendorID]             INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_JobVendorTemp_Staging] PRIMARY KEY CLUSTERED ([JobVendorsID] ASC)
);

