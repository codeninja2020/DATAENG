CREATE TABLE [TenMAID_US].[EmployeeGroups] (
    [EmployeeID]   INT NOT NULL,
    [GroupID]      INT NOT NULL,
    [ID]           INT NOT NULL,
    [PrimaryGroup] BIT NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeGroups] PRIMARY KEY CLUSTERED ([EmployeeID] ASC, [GroupID] ASC)
);

