CREATE TABLE [TenMAID_Global].[Groups] (
    [Description] NVARCHAR (200) NULL,
    [GroupID]     INT            NOT NULL,
    [Name]        NVARCHAR (50)  NOT NULL,
    [ParentID]    INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_Groups] PRIMARY KEY CLUSTERED ([GroupID] ASC)
);

