CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitPaymentMethod_Staging] (
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [PaymentMethodID]      INT            NOT NULL,
    [Title]                NVARCHAR (200) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitPaymentMethod_Staging] PRIMARY KEY CLUSTERED ([PaymentMethodID] ASC)
);

