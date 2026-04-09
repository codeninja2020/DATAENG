CREATE TABLE [TenMAID_Global].[Tbl_Members_CRMPreference_Staging] (
    [AreaInterestID]            INT          NULL,
    [ContactToMember]           INT          NULL,
    [CreatedBy]                 INT          NULL,
    [DateCreated]               DATETIME     NULL,
    [DateUpdated]               DATETIME     NULL,
    [ForeignMemberPreferenceID] INT          NULL,
    [MemberID]                  INT          NULL,
    [MemberOpinion]             INT          NULL,
    [MemberPreferenceID]        INT          NOT NULL,
    [UpdatedBy]                 INT          NULL,
    [SYS_CHANGE_OPERATION]      NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]        BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_Members_CRMPreference_Staging] PRIMARY KEY CLUSTERED ([MemberPreferenceID] ASC)
);

