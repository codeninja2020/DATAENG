CREATE TABLE [TenMAID_US].[Tbl_PvtIngenicoPaymentProfileMaster_Staging] (
    [ProfileID]            INT           NOT NULL,
    [ProfileName]          NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PvtIngenicoPaymentProfileMaster_Staging] PRIMARY KEY CLUSTERED ([ProfileID] ASC)
);

