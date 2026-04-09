CREATE TABLE [TenMAID_US].[EmployeeType_Staging] (
    [EmployeeTypeID]       INT          NOT NULL,
    [Name]                 VARCHAR (50) NULL,
    [OrderByColumn]        INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeType_Staging] PRIMARY KEY CLUSTERED ([EmployeeTypeID] ASC)
);

