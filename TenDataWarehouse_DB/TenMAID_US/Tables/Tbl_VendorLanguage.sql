CREATE TABLE [TenMAID_US].[Tbl_VendorLanguage] (
    [ID]       INT          NOT NULL,
    [LangID]   NVARCHAR (5) NOT NULL,
    [VendorID] INT          NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_VendorLanguage] PRIMARY KEY CLUSTERED ([ID] ASC)
);

