CREATE TABLE [TenMAID_US].[PVTCardCategory] (
    [AccountName]       NVARCHAR (50) NULL,
    [CategoryName]      NVARCHAR (50) NULL,
    [CurrencyID]        INT           NULL,
    [DisplayOrder]      INT           NULL,
    [PvtCardCategoryID] INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_US_PVTCardCategory] PRIMARY KEY CLUSTERED ([PvtCardCategoryID] ASC)
);

