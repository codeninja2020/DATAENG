CREATE TABLE [TenMAID_Global].[EmployeeType] (
    [EmployeeTypeID] INT          NOT NULL,
    [Name]           VARCHAR (50) NULL,
    [OrderByColumn]  INT          NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeType] PRIMARY KEY CLUSTERED ([EmployeeTypeID] ASC)
);

