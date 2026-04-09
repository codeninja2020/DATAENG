CREATE TABLE [TenMAID_Global].[GroupPermissions] (
    [GroupID]      INT NOT NULL,
    [ID]           INT NOT NULL,
    [PermissionID] INT NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_GroupPermissions] PRIMARY KEY CLUSTERED ([GroupID] ASC, [PermissionID] ASC)
);

