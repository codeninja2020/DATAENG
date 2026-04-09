CREATE TABLE [TenMAID_US].[PVTRefundMethods_Staging] (
    [Description]          NVARCHAR (50) NULL,
    [PvtRefMetID]          INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_PVTRefundMethods_Staging] PRIMARY KEY CLUSTERED ([PvtRefMetID] ASC)
);

