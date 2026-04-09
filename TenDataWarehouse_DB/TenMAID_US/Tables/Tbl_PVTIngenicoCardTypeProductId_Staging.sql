CREATE TABLE [TenMAID_US].[Tbl_PVTIngenicoCardTypeProductId_Staging] (
    [CardId]               INT          NOT NULL,
    [CardType]             INT          NULL,
    [IngenicoCardTypeId]   INT          NULL,
    [IngenicoProductId]    INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PVTIngenicoCardTypeProductId_Staging] PRIMARY KEY CLUSTERED ([CardId] ASC)
);

