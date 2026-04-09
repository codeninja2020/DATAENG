CREATE TABLE [TenMAID_US].[Tbl_PvtPaymentGatewayMaster] (
    [IsActive]          BIT            NULL,
    [PaymentGatwayID]   INT            NOT NULL,
    [PaymentGatwayName] NVARCHAR (100) NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PvtPaymentGatewayMaster] PRIMARY KEY CLUSTERED ([PaymentGatwayID] ASC)
);

