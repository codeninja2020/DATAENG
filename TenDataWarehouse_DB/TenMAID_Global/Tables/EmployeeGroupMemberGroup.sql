CREATE TABLE [TenMAID_Global].[EmployeeGroupMemberGroup] (
    [GroupID]       INT NOT NULL,
    [ID]            INT NOT NULL,
    [MemberGroupID] INT NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeGroupMemberGroup] PRIMARY KEY CLUSTERED ([GroupID] ASC, [MemberGroupID] ASC)
);

