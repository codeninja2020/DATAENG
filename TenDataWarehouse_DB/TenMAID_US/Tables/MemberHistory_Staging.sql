CREATE TABLE [TenMAID_US].[MemberHistory_Staging] (
    [DateOfCancellation]   DATETIME      NULL,
    [FeePayer]             NVARCHAR (50) NULL,
    [HistoryID]            INT           NOT NULL,
    [JoiningDate]          DATETIME      NULL,
    [MemberGroupID]        INT           NULL,
    [MemberID]             INT           NULL,
    [MembershipFees]       MONEY         NULL,
    [MembershipLength]     INT           NULL,
    [MembershipStatusID]   INT           NULL,
    [ParentID]             INT           NULL,
    [RenewalDue]           DATETIME      NULL,
    [SchemeID]             INT           NULL,
    [TimeOfUpdate]         DATETIME      NULL,
    [UpdatedBy]            INT           NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_MemberHistory_Staging] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

