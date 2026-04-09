CREATE TABLE [TenMAID_US].[EmployeeGroupRestrictionByScheme] (
    [GroupID]            INT NOT NULL,
    [GroupRestrictionID] INT NOT NULL,
    [SchemeID]           INT NOT NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeGroupRestrictionByScheme] PRIMARY KEY CLUSTERED ([GroupRestrictionID] ASC)
);

