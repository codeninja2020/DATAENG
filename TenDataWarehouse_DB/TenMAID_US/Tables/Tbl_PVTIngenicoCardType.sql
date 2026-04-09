CREATE TABLE [TenMAID_US].[Tbl_PVTIngenicoCardType] (
    [CardTypeID]        INT            NOT NULL,
    [CardTypeName]      NVARCHAR (150) NULL,
    [IngenicoProductId] INT            NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PVTIngenicoCardType] PRIMARY KEY CLUSTERED ([CardTypeID] ASC)
);

