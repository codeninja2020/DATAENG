CREATE TABLE [TenMAID_US].[EmployeeHistory] (
    [Active]              BIT      NULL,
    [DateUpdated]         DATETIME NULL,
    [EmployeeID]          INT      NOT NULL,
    [HistoryID]           INT      NOT NULL,
    [ManagerID]           INT      NULL,
    [NewRegionID]         INT      NULL,
    [NewSpecialistTeamID] INT      NULL,
    [NewSubRegionID]      INT      NULL,
    [NewSubTeamID]        INT      NULL,
    [NewTeamID]           INT      NULL,
    [ParentID]            INT      NULL,
    [SubTeamID]           SMALLINT NULL,
    [TeamID]              SMALLINT NULL,
    [UpdatedBy]           INT      NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeHistory] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

