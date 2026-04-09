CREATE TABLE [TenMAID_US].[Tbl_Vendor_App_Category_Staging] (
    [AppCategoryTypeID]    INT           NOT NULL,
    [AppCategoryTypeValue] VARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_Vendor_App_Category_Staging] PRIMARY KEY CLUSTERED ([AppCategoryTypeID] ASC)
);

