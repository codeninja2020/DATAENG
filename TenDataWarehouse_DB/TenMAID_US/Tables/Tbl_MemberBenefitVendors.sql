CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitVendors] (
    [DateCreated]     DATETIME NULL,
    [DateUpdated]     DATETIME NULL,
    [ID]              INT      NOT NULL,
    [MemberBenefitID] INT      NULL,
    [VendorBranchID]  INT      NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitVendors] PRIMARY KEY CLUSTERED ([ID] ASC)
);

