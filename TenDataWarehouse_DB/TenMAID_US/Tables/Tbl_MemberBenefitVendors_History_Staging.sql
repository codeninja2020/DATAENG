CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitVendors_History_Staging] (
    [DateCreated]          DATETIME     NULL,
    [DateDeleted]          DATETIME     NULL,
    [ID]                   INT          NOT NULL,
    [MemberBenefitID]      INT          NULL,
    [VendorBranchID]       INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitVendors_History_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

