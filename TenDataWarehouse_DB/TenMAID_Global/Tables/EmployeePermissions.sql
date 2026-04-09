CREATE TABLE [TenMAID_Global].[EmployeePermissions] (
    [EmployeeID]            INT NOT NULL,
    [EmployeePermissionsID] INT NOT NULL,
    [PermissionID]          INT NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeePermissions] PRIMARY KEY CLUSTERED ([EmployeePermissionsID] ASC)
);

