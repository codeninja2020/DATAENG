CREATE TABLE [TenMAID_Global].[CorporateStatus_Staging] (
    [CorporateStatusID]    INT           NOT NULL,
    [Name]                 NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_CorporateStatus_Staging] PRIMARY KEY CLUSTERED ([CorporateStatusID] ASC)
);

