CREATE TABLE [TenMAID_Global].[EmployeeGroups] (
    [EmployeeID]   INT NOT NULL,
    [GroupID]      INT NOT NULL,
    [ID]           INT NOT NULL,
    [PrimaryGroup] BIT NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeGroups] PRIMARY KEY CLUSTERED ([EmployeeID] ASC, [GroupID] ASC)
);

