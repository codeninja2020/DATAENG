CREATE TABLE [TenMAID_US].[Tbl_FieldVendorExtraInfoControlValues] (
    [ControlID]    INT            NULL,
    [ControlValue] NVARCHAR (100) NULL,
    [FieldID]      INT            NOT NULL,
    [ID]           INT            NOT NULL,
    [IsActive]     BIT            NULL,
    [IsDefault]    BIT            NULL,
    [LangID]       NVARCHAR (5)   NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_FieldVendorExtraInfoControlValues] PRIMARY KEY CLUSTERED ([ID] ASC)
);

