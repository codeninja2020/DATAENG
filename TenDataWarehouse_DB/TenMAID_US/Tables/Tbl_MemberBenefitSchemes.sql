CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitSchemes] (
    [DateCreated]     DATETIME NULL,
    [DateUpdated]     DATETIME NULL,
    [ID]              INT      NOT NULL,
    [MemberBenefitID] INT      NULL,
    [SchemeID]        INT      NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitSchemes] PRIMARY KEY CLUSTERED ([ID] ASC)
);

