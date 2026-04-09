CREATE TABLE [TenMAID_Global].[EmployeeGroupRestrictionByScheme] (
    [GroupID]            INT NOT NULL,
    [GroupRestrictionID] INT NOT NULL,
    [SchemeID]           INT NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeGroupRestrictionByScheme] PRIMARY KEY CLUSTERED ([GroupRestrictionID] ASC)
);

