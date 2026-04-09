CREATE TABLE [TenMAID_US].[Tbl_PVTIngenicoCardTypeProductId] (
    [CardId]             INT NOT NULL,
    [CardType]           INT NULL,
    [IngenicoCardTypeId] INT NULL,
    [IngenicoProductId]  INT NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PVTIngenicoCardTypeProductId] PRIMARY KEY CLUSTERED ([CardId] ASC)
);

