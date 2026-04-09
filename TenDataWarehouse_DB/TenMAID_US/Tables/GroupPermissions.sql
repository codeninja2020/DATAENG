CREATE TABLE [TenMAID_US].[GroupPermissions] (
    [GroupID]      INT NOT NULL,
    [ID]           INT NOT NULL,
    [PermissionID] INT NOT NULL,
    CONSTRAINT [PK_TenMAID_US_GroupPermissions] PRIMARY KEY CLUSTERED ([GroupID] ASC, [PermissionID] ASC)
);

