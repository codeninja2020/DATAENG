CREATE TABLE [TenMAID_Global].[Tbl_PvtIngenicoPaymentProfileMaster_Staging] (
    [ProfileID]            INT           NOT NULL,
    [ProfileName]          NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_PvtIngenicoPaymentProfileMaster_Staging] PRIMARY KEY CLUSTERED ([ProfileID] ASC)
);

