CREATE TABLE [TenMAID_Global].[PVTRefundMethods_Staging] (
    [Description]          NVARCHAR (50) NULL,
    [PvtRefMetID]          INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_PVTRefundMethods_Staging] PRIMARY KEY CLUSTERED ([PvtRefMetID] ASC)
);

