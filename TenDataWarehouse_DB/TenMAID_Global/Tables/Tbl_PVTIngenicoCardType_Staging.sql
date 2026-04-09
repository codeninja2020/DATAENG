CREATE TABLE [TenMAID_Global].[Tbl_PVTIngenicoCardType_Staging] (
    [CardTypeID]           INT            NOT NULL,
    [CardTypeName]         NVARCHAR (150) NULL,
    [IngenicoProductId]    INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_PVTIngenicoCardType_Staging] PRIMARY KEY CLUSTERED ([CardTypeID] ASC)
);

