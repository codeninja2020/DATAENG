CREATE TABLE [TenMAID_Global].[EmployeeGroupMemberGroup_Staging] (
    [GroupID]              INT          NOT NULL,
    [ID]                   INT          NULL,
    [MemberGroupID]        INT          NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeGroupMemberGroup_Staging] PRIMARY KEY CLUSTERED ([GroupID] ASC, [MemberGroupID] ASC)
);

