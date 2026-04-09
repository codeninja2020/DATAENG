CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitPaymentMethod] (
    [DateCreated]     DATETIME       NULL,
    [DateUpdated]     DATETIME       NULL,
    [PaymentMethodID] INT            NOT NULL,
    [Title]           NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitPaymentMethod] PRIMARY KEY CLUSTERED ([PaymentMethodID] ASC)
);

