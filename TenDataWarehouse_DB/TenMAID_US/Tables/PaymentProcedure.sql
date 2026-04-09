CREATE TABLE [TenMAID_US].[PaymentProcedure] (
    [PaymentProcDesc] NVARCHAR (100) NULL,
    [PaymentProcID]   INT            NOT NULL,
    [PaymentProcText] NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_TenMAID_US_PaymentProcedure] PRIMARY KEY CLUSTERED ([PaymentProcID] ASC)
);

