CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitJobTemp] (
    [DateCreated]     DATETIME       NULL,
    [DateUpdated]     DATETIME       NULL,
    [ID]              INT            NOT NULL,
    [IsRedeemed]      BIT            NULL,
    [MemberBenefitID] INT            NULL,
    [TempJobID]       NVARCHAR (100) NULL,
    [VendorBranchID]  INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitJobTemp] PRIMARY KEY CLUSTERED ([ID] ASC)
);

