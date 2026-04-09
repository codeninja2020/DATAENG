CREATE TABLE [TenMAID_Global].[EmployeesTeam_Staging] (
    [TeamID]               INT            IDENTITY (1, 1) NOT NULL,
    [TeamName]             NVARCHAR (150) NULL,
    [ParentID]             INT            NULL,
    [FinanceCode]          NVARCHAR (50)  NULL,
    [RegionID]             INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TENMAID_Global_EmployeesTeam_Staging] PRIMARY KEY CLUSTERED ([TeamID] ASC)
);

