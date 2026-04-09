CREATE TABLE [TenMAID_Global].[Tbl_MemberTravelCompaniondtl_Staging] (
    [CompanionID]          INT           NOT NULL,
    [MemberID]             INT           NULL,
    [FirstName]            NVARCHAR (50) NULL,
    [LastName]             NVARCHAR (50) NULL,
    [DOB]                  DATETIME      NULL,
    [IsMember]             BIT           NULL,
    [RelationWithMember]   NVARCHAR (50) NULL,
    [DateCreated]          DATETIME      NULL,
    [DateUpdated]          DATETIME      NULL,
    [CreatedBy]            INT           NULL,
    [UpdatedBy]            INT           NULL,
    [ForeignCompanionID]   INT           NULL,
    [ForeignMemberID]      INT           NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_Tbl_MemberTravelCompaniondtl_Staging] PRIMARY KEY CLUSTERED ([CompanionID] ASC)
);

