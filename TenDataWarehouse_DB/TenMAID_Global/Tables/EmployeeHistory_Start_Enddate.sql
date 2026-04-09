CREATE TABLE [TenMAID_Global].[EmployeeHistory_Start_Enddate] (
    [EmployeeID]                      INT      NOT NULL,
    [SubteamEndDate]                  DATETIME NULL,
    [subTeamid]                       SMALLINT NULL,
    [SubteamStartDate]                DATETIME NULL,
    [EmployeeHistory_Start_EnddateId] INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_EmployeeHistory_Start_EnddateId] PRIMARY KEY CLUSTERED ([EmployeeHistory_Start_EnddateId] ASC)
);

