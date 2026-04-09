CREATE TABLE [TenMAID_US].[EmployeeJobs] (
    [EmployeeID]    INT      NOT NULL,
    [EmployeeJobID] INT      NOT NULL,
    [JobID]         INT      NOT NULL,
    [Role]          SMALLINT NULL,
    [WhenAssigned]  DATETIME NULL,
    [WhoAssigned]   INT      NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeJobs] PRIMARY KEY CLUSTERED ([EmployeeJobID] ASC)
);

