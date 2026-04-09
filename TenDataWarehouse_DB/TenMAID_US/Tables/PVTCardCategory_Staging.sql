CREATE TABLE [TenMAID_US].[PVTCardCategory_Staging] (
    [AccountName]          NVARCHAR (50) NULL,
    [CategoryName]         NVARCHAR (50) NULL,
    [CurrencyID]           INT           NULL,
    [DisplayOrder]         INT           NULL,
    [PvtCardCategoryID]    INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_PVTCardCategory_Staging] PRIMARY KEY CLUSTERED ([PvtCardCategoryID] ASC)
);

