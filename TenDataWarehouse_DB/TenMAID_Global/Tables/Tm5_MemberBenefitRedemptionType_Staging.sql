CREATE TABLE [TenMAID_Global].[Tm5_MemberBenefitRedemptionType_Staging] (
    [RedemptionType]       NVARCHAR (50) NULL,
    [RedemptionTypeID]     INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_Tm5_MemberBenefitRedemptionType_Staging] PRIMARY KEY CLUSTERED ([RedemptionTypeID] ASC)
);

