CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitJobTemp_Staging] (
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [ID]                   INT            NOT NULL,
    [IsRedeemed]           BIT            NULL,
    [MemberBenefitID]      INT            NULL,
    [TempJobID]            NVARCHAR (100) NULL,
    [VendorBranchID]       INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitJobTemp_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

