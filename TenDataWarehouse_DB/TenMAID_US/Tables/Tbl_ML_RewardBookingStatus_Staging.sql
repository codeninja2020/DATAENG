CREATE TABLE [TenMAID_US].[Tbl_ML_RewardBookingStatus_Staging] (
    [Description]          NVARCHAR (50) NULL,
    [ID]                   INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_ML_RewardBookingStatus_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

