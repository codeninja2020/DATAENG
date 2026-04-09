CREATE TABLE [TenMAID_US].[EmployeeGroups_Staging] (
    [EmployeeID]           INT          NOT NULL,
    [GroupID]              INT          NOT NULL,
    [ID]                   INT          NULL,
    [PrimaryGroup]         BIT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeGroups_Staging] PRIMARY KEY CLUSTERED ([EmployeeID] ASC, [GroupID] ASC)
);

