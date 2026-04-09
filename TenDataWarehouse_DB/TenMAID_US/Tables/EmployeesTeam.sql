CREATE TABLE [TenMAID_US].[EmployeesTeam] (
    [TeamID]      INT            IDENTITY (1, 1) NOT NULL,
    [TeamName]    NVARCHAR (150) NULL,
    [ParentID]    INT            NULL,
    [FinanceCode] NVARCHAR (50)  NULL,
    [RegionID]    INT            NULL,
    CONSTRAINT [PK_TENMAID_US_EmployeesTeam] PRIMARY KEY CLUSTERED ([TeamID] ASC)
);

