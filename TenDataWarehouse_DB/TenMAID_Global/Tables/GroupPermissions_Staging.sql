CREATE TABLE [TenMAID_Global].[GroupPermissions_Staging] (
    [GroupID]              INT          NOT NULL,
    [ID]                   INT          NULL,
    [PermissionID]         INT          NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_GroupPermissions_Staging] PRIMARY KEY CLUSTERED ([GroupID] ASC, [PermissionID] ASC)
);

