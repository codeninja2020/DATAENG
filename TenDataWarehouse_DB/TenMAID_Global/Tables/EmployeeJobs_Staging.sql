CREATE TABLE [TenMAID_Global].[EmployeeJobs_Staging] (
    [EmployeeID]           INT          NULL,
    [EmployeeJobID]        INT          NOT NULL,
    [JobID]                INT          NULL,
    [Role]                 SMALLINT     NULL,
    [WhenAssigned]         DATETIME     NULL,
    [WhoAssigned]          INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeJobs_Staging] PRIMARY KEY CLUSTERED ([EmployeeJobID] ASC)
);

