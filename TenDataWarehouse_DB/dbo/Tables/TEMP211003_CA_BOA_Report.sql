CREATE TABLE [dbo].[TEMP211003_CA_BOA_Report] (
    [external_reference]     NVARCHAR (50)  NOT NULL,
    [loyalty_system_id]      NVARCHAR (100) NOT NULL,
    [completed_at]           NVARCHAR (100) NOT NULL,
    [member_id]              INT            NOT NULL,
    [sub_category]           NVARCHAR (50)  NULL,
    [promotion_code]         NVARCHAR (100) NULL,
    [loyalty_amount]         SMALLINT       NULL,
    [fiat_amount]            FLOAT (53)     NULL,
    [channel]                NVARCHAR (50)  NOT NULL,
    [redemption_type]        NVARCHAR (50)  NOT NULL,
    [total_amount]           FLOAT (53)     NULL,
    [rewards_vendor_id]      FLOAT (53)     NOT NULL,
    [group_code]             NVARCHAR (50)  NOT NULL,
    [program_id]             NVARCHAR (100) NULL,
    [top_parent_transaction] NVARCHAR (50)  NULL
);

