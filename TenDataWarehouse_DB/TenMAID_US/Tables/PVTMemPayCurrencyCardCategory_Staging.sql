CREATE TABLE [TenMAID_US].[PVTMemPayCurrencyCardCategory_Staging] (
    [ISO_CurrencyID]        INT          NULL,
    [PvtCardCategoryID]     INT          NULL,
    [PvtMemPayCurCardCatID] INT          NOT NULL,
    [SYS_CHANGE_OPERATION]  NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]    BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_PVTMemPayCurrencyCardCategory_Staging] PRIMARY KEY CLUSTERED ([PvtMemPayCurCardCatID] ASC)
);

