CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitSchemes_Staging] (
    [DateCreated]          DATETIME     NULL,
    [DateUpdated]          DATETIME     NULL,
    [ID]                   INT          NOT NULL,
    [MemberBenefitID]      INT          NULL,
    [SchemeID]             INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitSchemes_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

