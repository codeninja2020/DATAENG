CREATE TABLE [TenMAID_Global].[tm5_PVTAuthExpType_Staging] (
    [Description]          NVARCHAR (100) NULL,
    [PvtAuthExpTypID]      INT            NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_PVTAuthExpType_Staging] PRIMARY KEY CLUSTERED ([PvtAuthExpTypID] ASC)
);

