CREATE TABLE [TenMAID_Global].[EmployeeJobs] (
    [EmployeeID]    INT      NOT NULL,
    [EmployeeJobID] INT      NOT NULL,
    [JobID]         INT      NOT NULL,
    [Role]          SMALLINT NULL,
    [WhenAssigned]  DATETIME NULL,
    [WhoAssigned]   INT      NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeJobs] PRIMARY KEY CLUSTERED ([EmployeeJobID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_JobID_Role_INC]
    ON [TenMAID_Global].[EmployeeJobs]([JobID] ASC, [Role] ASC)
    INCLUDE([EmployeeID]);


GO
CREATE NONCLUSTERED INDEX [IX_Role_INC]
    ON [TenMAID_Global].[EmployeeJobs]([Role] ASC)
    INCLUDE([EmployeeID], [JobID]);


GO
CREATE NONCLUSTERED INDEX [IX_WhenAssigned_INC]
    ON [TenMAID_Global].[EmployeeJobs]([WhenAssigned] ASC)
    INCLUDE([EmployeeID], [JobID], [Role], [WhoAssigned]);

