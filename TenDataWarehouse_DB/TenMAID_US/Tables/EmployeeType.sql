CREATE TABLE [TenMAID_US].[EmployeeType] (
    [EmployeeTypeID] INT          NOT NULL,
    [Name]           VARCHAR (50) NULL,
    [OrderByColumn]  INT          NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeType] PRIMARY KEY CLUSTERED ([EmployeeTypeID] ASC)
);

