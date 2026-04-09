CREATE TABLE [TenMAID_Global].[Tbl_FieldVendorExtraInfoControlValues_Staging] (
    [ControlID]            INT            NULL,
    [ControlValue]         NVARCHAR (100) NULL,
    [FieldID]              INT            NULL,
    [ID]                   INT            NOT NULL,
    [IsActive]             BIT            NULL,
    [IsDefault]            BIT            NULL,
    [LangID]               NVARCHAR (5)   NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_FieldVendorExtraInfoControlValues_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

