CREATE TABLE [TenMAID_Global].[Tbl_FieldVendorExtraInfoControlValues] (
    [ControlID]    INT            NULL,
    [ControlValue] NVARCHAR (100) NULL,
    [FieldID]      INT            NOT NULL,
    [ID]           INT            NOT NULL,
    [IsActive]     BIT            NULL,
    [IsDefault]    BIT            NULL,
    [LangID]       NVARCHAR (5)   NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_FieldVendorExtraInfoControlValues] PRIMARY KEY CLUSTERED ([ID] ASC)
);

