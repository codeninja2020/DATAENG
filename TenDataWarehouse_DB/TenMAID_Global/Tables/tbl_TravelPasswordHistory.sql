CREATE TABLE [TenMAID_Global].[tbl_TravelPasswordHistory] (
    [HistoryID]                INT      NOT NULL,
    [EmployeeID]               INT      NULL,
    [MemberID]                 INT      NULL,
    [CompanionID]              INT      NULL,
    [TravelCompanionProfileID] INT      NULL,
    [Dateviewed]               DATETIME NULL,
    CONSTRAINT [PK_tbl_TravelPasswordHistory] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

