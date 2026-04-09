CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitJobs] (
    [DateCreated]     DATETIME NULL,
    [DateUpdated]     DATETIME NULL,
    [ID]              INT      NOT NULL,
    [IsRedeemed]      BIT      NULL,
    [isSelected]      BIT      NULL,
    [JobID]           INT      NULL,
    [MemberBenefitID] INT      NULL,
    [VendorBranchID]  INT      NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitJobs] PRIMARY KEY CLUSTERED ([ID] ASC)
);

