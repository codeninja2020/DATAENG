CREATE TABLE [TenMAID_Global].[MemberGroupsName_Staging] (
    [MemberGroupName]      NVARCHAR (12) NULL,
    [MemberID]             INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_MemberGroupsName_Staging] PRIMARY KEY CLUSTERED ([MemberID] ASC)
);

