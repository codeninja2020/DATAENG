CREATE TABLE [TenMAID_US].[PaymentProcedure_Staging] (
    [PaymentProcDesc]      NVARCHAR (100) NULL,
    [PaymentProcID]        INT            NOT NULL,
    [PaymentProcText]      NVARCHAR (50)  NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_PaymentProcedure_Staging] PRIMARY KEY CLUSTERED ([PaymentProcID] ASC)
);

