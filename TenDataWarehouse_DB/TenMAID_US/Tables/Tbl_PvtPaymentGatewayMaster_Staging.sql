CREATE TABLE [TenMAID_US].[Tbl_PvtPaymentGatewayMaster_Staging] (
    [IsActive]             BIT            NULL,
    [PaymentGatwayID]      INT            NOT NULL,
    [PaymentGatwayName]    NVARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PvtPaymentGatewayMaster_Staging] PRIMARY KEY CLUSTERED ([PaymentGatwayID] ASC)
);

