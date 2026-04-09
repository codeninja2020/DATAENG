CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitRedemptionMethod_Staging] (
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [Description]          NVARCHAR (2000) NULL,
    [RedMethodID]          INT             NOT NULL,
    [Title]                NVARCHAR (200)  NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitRedemptionMethod_Staging] PRIMARY KEY CLUSTERED ([RedMethodID] ASC)
);

