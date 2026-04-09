CREATE TABLE [TenMAID_Global].[Tbl_PVTIngenicoCardType] (
    [CardTypeID]        INT            NOT NULL,
    [CardTypeName]      NVARCHAR (150) NULL,
    [IngenicoProductId] INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_PVTIngenicoCardType] PRIMARY KEY CLUSTERED ([CardTypeID] ASC)
);

