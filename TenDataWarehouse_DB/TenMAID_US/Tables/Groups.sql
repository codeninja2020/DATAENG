CREATE TABLE [TenMAID_US].[Groups] (
    [Description] NVARCHAR (200) NULL,
    [GroupID]     INT            NOT NULL,
    [Name]        NVARCHAR (50)  NOT NULL,
    [ParentID]    INT            NULL,
    CONSTRAINT [PK_TenMAID_US_Groups] PRIMARY KEY CLUSTERED ([GroupID] ASC)
);

