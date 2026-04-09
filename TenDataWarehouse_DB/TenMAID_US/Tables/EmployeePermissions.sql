CREATE TABLE [TenMAID_US].[EmployeePermissions] (
    [EmployeeID]            INT NOT NULL,
    [EmployeePermissionsID] INT NOT NULL,
    [PermissionID]          INT NOT NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeePermissions] PRIMARY KEY CLUSTERED ([EmployeePermissionsID] ASC)
);

