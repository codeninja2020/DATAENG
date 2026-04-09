CREATE TABLE [dbo].[zzViator_BookingData_Backup_20241024] (
    [Viator_BookingDataID]     INT             IDENTITY (1, 1) NOT NULL,
    [booking_reference]        CHAR (100)      NULL,
    [source_reference]         CHAR (100)      NULL,
    [client_booking_reference] CHAR (100)      NULL,
    [created]                  DATETIME2 (7)   NULL,
    [updated]                  DATETIME2 (7)   NULL,
    [status]                   CHAR (100)      NULL,
    [customer_first_name]      CHAR (100)      NULL,
    [customer_last_name]       CHAR (100)      NULL,
    [total_cost]               DECIMAL (10, 2) NULL,
    [total_margin]             DECIMAL (10, 2) NULL,
    [total_price]              DECIMAL (10, 2) NULL,
    [base_currency_code]       CHAR (100)      NULL,
    [selling_price]            DECIMAL (10, 2) NULL,
    [selling_currency_code]    CHAR (100)      NULL,
    [selling_exchange_rate]    INT             NULL,
    [booking_components]       CHAR (1000)     NULL,
    [payment_components]       CHAR (1000)     NULL,
    [InsertedOn]               DATETIME        NULL,
    [FileName]                 NVARCHAR (2000) NULL
);

