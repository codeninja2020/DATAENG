CREATE TABLE [TenMAID_US].[Tbl_PvtIngenicoSubAccount_Staging] (
    [SubAccountID]         INT            NOT NULL,
    [SubAccountName]       NVARCHAR (150) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_PvtIngenicoSubAccount_Staging] PRIMARY KEY CLUSTERED ([SubAccountID] ASC)
);

