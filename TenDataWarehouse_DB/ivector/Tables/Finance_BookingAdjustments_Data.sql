CREATE TABLE [ivector].[Finance_BookingAdjustments_Data] (
    [Finance_BookingAdjustmentsID]       INT            IDENTITY (1, 1) NOT NULL,
    [Booking Reference]                  NVARCHAR (255) NULL,
    [Booking Adjustment Type]            NVARCHAR (255) NULL,
    [Cancelled]                          NVARCHAR (255) NULL,
    [Commissionable]                     NVARCHAR (255) NULL,
    [Date Added]                         DATETIME       NULL,
    [Selling Exchange Rate]              FLOAT (53)     NULL,
    [Component Reference]                NVARCHAR (255) NULL,
    [Adjustment Value (Sell Currency)]   FLOAT (53)     NULL,
    [Adjustment Amount (GBP)]            FLOAT (53)     NULL,
    [Adjustment Cost]                    FLOAT (53)     NULL,
    [Commission]                         NVARCHAR (255) NULL,
    [Local Adjustment Cost]              FLOAT (53)     NULL,
    [Pre Cancellation Adjustment Amount] FLOAT (53)     NULL,
    [InsertedOn]                         DATETIME2 (7)  NULL,
    [FileName]                           NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([Finance_BookingAdjustmentsID] ASC)
);

