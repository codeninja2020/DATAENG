CREATE TABLE [TenMAID_US].[EmployeeGroupMemberGroup] (
    [GroupID]       INT NOT NULL,
    [ID]            INT NOT NULL,
    [MemberGroupID] INT NOT NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeGroupMemberGroup] PRIMARY KEY CLUSTERED ([GroupID] ASC, [MemberGroupID] ASC)
);

