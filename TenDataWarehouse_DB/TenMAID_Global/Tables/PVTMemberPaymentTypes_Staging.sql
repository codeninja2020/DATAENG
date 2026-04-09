CREATE TABLE [TenMAID_Global].[PVTMemberPaymentTypes_Staging] (
    [Description]          NVARCHAR (50) NULL,
    [PvtMemPayTypID]       INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_PVTMemberPaymentTypes_Staging] PRIMARY KEY CLUSTERED ([PvtMemPayTypID] ASC)
);

