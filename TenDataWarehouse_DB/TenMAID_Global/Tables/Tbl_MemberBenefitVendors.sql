CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitVendors] (
    [DateCreated]     DATETIME NULL,
    [DateUpdated]     DATETIME NULL,
    [ID]              INT      NOT NULL,
    [MemberBenefitID] INT      NULL,
    [VendorBranchID]  INT      NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitVendors] PRIMARY KEY CLUSTERED ([ID] ASC)
);

