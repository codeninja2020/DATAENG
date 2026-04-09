CREATE TABLE [CurrencyAlliance].[BOA_ReportFile_Backup] (
    [external_reference]     NVARCHAR (50)   NOT NULL,
    [loyalty_system_id]      NVARCHAR (50)   NOT NULL,
    [completed_at]           NVARCHAR (50)   NOT NULL,
    [member_id]              NVARCHAR (256)  NOT NULL,
    [sub_category]           NVARCHAR (50)   NULL,
    [promotion_code]         NVARCHAR (50)   NULL,
    [loyalty_amount]         INT             NULL,
    [fiat_amount]            FLOAT (53)      NULL,
    [channel]                NVARCHAR (50)   NOT NULL,
    [redemption_type]        NVARCHAR (50)   NOT NULL,
    [total_amount]           FLOAT (53)      NULL,
    [rewards_vendor_id]      NVARCHAR (50)   NOT NULL,
    [group_code]             NVARCHAR (100)  NULL,
    [program_id]             NVARCHAR (100)  NULL,
    [InsertedOn]             DATETIME        NULL,
    [FileName]               NVARCHAR (1000) NULL,
    [top_parent_transaction] NVARCHAR (100)  NULL
);

