CREATE TABLE [TenMAID_Global].[MemberHistory] (
    [DateOfCancellation] DATETIME      NULL,
    [FeePayer]           NVARCHAR (50) NULL,
    [HistoryID]          INT           NOT NULL,
    [JoiningDate]        DATETIME      NULL,
    [MemberGroupID]      INT           NULL,
    [MemberID]           INT           NOT NULL,
    [MembershipFees]     MONEY         NULL,
    [MembershipLength]   INT           NULL,
    [MembershipStatusID] INT           NULL,
    [ParentID]           INT           NULL,
    [RenewalDue]         DATETIME      NULL,
    [SchemeID]           INT           NULL,
    [TimeOfUpdate]       DATETIME      NULL,
    [UpdatedBy]          INT           NULL,
    CONSTRAINT [PK_TenMAID_Global_MemberHistory] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

