CREATE TABLE [TenMAID_US].[EmployeeHistory_Staging] (
    [Active]               BIT          NULL,
    [DateUpdated]          DATETIME     NULL,
    [EmployeeID]           INT          NULL,
    [HistoryID]            INT          NOT NULL,
    [ManagerID]            INT          NULL,
    [NewRegionID]          INT          NULL,
    [NewSpecialistTeamID]  INT          NULL,
    [NewSubRegionID]       INT          NULL,
    [NewSubTeamID]         INT          NULL,
    [NewTeamID]            INT          NULL,
    [ParentID]             INT          NULL,
    [SubTeamID]            SMALLINT     NULL,
    [TeamID]               SMALLINT     NULL,
    [UpdatedBy]            INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_EmployeeHistory_Staging] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

