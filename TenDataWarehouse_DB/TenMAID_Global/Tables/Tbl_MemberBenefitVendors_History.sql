CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitVendors_History] (
    [DateCreated]     DATETIME NULL,
    [DateDeleted]     DATETIME NULL,
    [ID]              INT      NOT NULL,
    [MemberBenefitID] INT      NULL,
    [VendorBranchID]  INT      NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitVendors_History] PRIMARY KEY CLUSTERED ([ID] ASC)
);

