CREATE TABLE [TenMAID_Global].[PVTRefundMethods] (
    [Description] NVARCHAR (50) NULL,
    [PvtRefMetID] INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_PVTRefundMethods] PRIMARY KEY CLUSTERED ([PvtRefMetID] ASC)
);

