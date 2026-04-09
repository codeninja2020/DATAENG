CREATE TABLE [TenMAID_US].[Tbl_VendorLanguage_Staging] (
    [ID]                   INT          NOT NULL,
    [LangID]               NVARCHAR (5) NULL,
    [VendorID]             INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_VendorLanguage_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

