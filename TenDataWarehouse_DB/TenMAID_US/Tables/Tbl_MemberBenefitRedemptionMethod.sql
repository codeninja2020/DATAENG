CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitRedemptionMethod] (
    [DateCreated] DATETIME        NULL,
    [DateUpdated] DATETIME        NULL,
    [Description] NVARCHAR (2000) NULL,
    [RedMethodID] INT             NOT NULL,
    [Title]       NVARCHAR (200)  NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitRedemptionMethod] PRIMARY KEY CLUSTERED ([RedMethodID] ASC)
);

