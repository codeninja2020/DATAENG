CREATE TABLE [TenMAID_Global].[Tbl_Members_CRMPreference] (
    [AreaInterestID]            INT      NOT NULL,
    [ContactToMember]           INT      NULL,
    [CreatedBy]                 INT      NULL,
    [DateCreated]               DATETIME NULL,
    [DateUpdated]               DATETIME NULL,
    [ForeignMemberPreferenceID] INT      NULL,
    [MemberID]                  INT      NOT NULL,
    [MemberOpinion]             INT      NULL,
    [MemberPreferenceID]        INT      NOT NULL,
    [UpdatedBy]                 INT      NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_Members_CRMPreference] PRIMARY KEY CLUSTERED ([MemberPreferenceID] ASC)
);

