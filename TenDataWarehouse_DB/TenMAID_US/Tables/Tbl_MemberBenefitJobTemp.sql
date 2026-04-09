CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitJobTemp] (
    [DateCreated]     DATETIME       NULL,
    [DateUpdated]     DATETIME       NULL,
    [ID]              INT            NOT NULL,
    [IsRedeemed]      BIT            NULL,
    [MemberBenefitID] INT            NULL,
    [TempJobID]       NVARCHAR (100) NULL,
    [VendorBranchID]  INT            NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitJobTemp] PRIMARY KEY CLUSTERED ([ID] ASC)
);

