CREATE TABLE [TenMAID_Global].[Tbl_PvtPaymentGatewayMaster] (
    [IsActive]          BIT            NULL,
    [PaymentGatwayID]   INT            NOT NULL,
    [PaymentGatwayName] NVARCHAR (100) NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_PvtPaymentGatewayMaster] PRIMARY KEY CLUSTERED ([PaymentGatwayID] ASC)
);

