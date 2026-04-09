CREATE TABLE [TenMAID_Global].[Tbl_VendorLanguage] (
    [ID]       INT          NOT NULL,
    [LangID]   NVARCHAR (5) NOT NULL,
    [VendorID] INT          NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_VendorLanguage] PRIMARY KEY CLUSTERED ([ID] ASC)
);

