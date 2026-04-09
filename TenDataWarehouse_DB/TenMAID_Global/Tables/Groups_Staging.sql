CREATE TABLE [TenMAID_Global].[Groups_Staging] (
    [Description]          NVARCHAR (200) NULL,
    [GroupID]              INT            NOT NULL,
    [Name]                 NVARCHAR (50)  NULL,
    [ParentID]             INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Groups_Staging] PRIMARY KEY CLUSTERED ([GroupID] ASC)
);

