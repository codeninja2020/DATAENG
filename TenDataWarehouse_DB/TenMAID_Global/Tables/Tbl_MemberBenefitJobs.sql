CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitJobs] (
    [DateCreated]     DATETIME NULL,
    [DateUpdated]     DATETIME NULL,
    [ID]              INT      NOT NULL,
    [IsRedeemed]      BIT      NULL,
    [isSelected]      BIT      NULL,
    [JobID]           INT      NULL,
    [MemberBenefitID] INT      NULL,
    [VendorBranchID]  INT      NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitJobs] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_JobID]
    ON [TenMAID_Global].[Tbl_MemberBenefitJobs]([JobID] ASC);

