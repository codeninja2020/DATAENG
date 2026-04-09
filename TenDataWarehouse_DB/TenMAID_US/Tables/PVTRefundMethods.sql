CREATE TABLE [TenMAID_US].[PVTRefundMethods] (
    [Description] NVARCHAR (50) NULL,
    [PvtRefMetID] INT           NOT NULL,
    CONSTRAINT [PK_TenMAID_US_PVTRefundMethods] PRIMARY KEY CLUSTERED ([PvtRefMetID] ASC)
);

