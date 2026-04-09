CREATE TABLE [TenMAID_US].[EmployeePermissions_Staging] (
    [EmployeeID]            INT          NULL,
    [EmployeePermissionsID] INT          NOT NULL,
    [PermissionID]          INT          NULL,
    [SYS_CHANGE_OPERATION]  NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]    BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeePermissions_Staging] PRIMARY KEY CLUSTERED ([EmployeePermissionsID] ASC)
);

