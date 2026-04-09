CREATE TABLE [TenMAID_Global].[tbl_TravelPasswordHistory_Staging] (
    [HistoryID]                INT          NOT NULL,
    [EmployeeID]               INT          NULL,
    [MemberID]                 INT          NULL,
    [CompanionID]              INT          NULL,
    [TravelCompanionProfileID] INT          NULL,
    [Dateviewed]               DATETIME     NULL,
    [SYS_CHANGE_OPERATION]     NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]       BIGINT       NULL,
    CONSTRAINT [PK_tbl_TravelPasswordHistory_Staging] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

