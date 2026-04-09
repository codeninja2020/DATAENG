CREATE TABLE [TenMAID_Global].[MembershipStatus_Staging] (
    [MembershipStatusID]   INT            NOT NULL,
    [Name]                 NVARCHAR (50)  NOT NULL,
    [Description]          NVARCHAR (200) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TENMAID_Global_MembershipStatus_Staging] PRIMARY KEY CLUSTERED ([MembershipStatusID] ASC)
);

