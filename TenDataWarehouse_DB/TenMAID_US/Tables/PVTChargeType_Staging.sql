CREATE TABLE [TenMAID_US].[PVTChargeType_Staging] (
    [Description]          NVARCHAR (50) NULL,
    [PvtChaTypID]          INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_PVTChargeType_Staging] PRIMARY KEY CLUSTERED ([PvtChaTypID] ASC)
);

