CREATE TABLE [TenMAID_Global].[Tbl_MemberSportsDetails_Staging] (
    [SportsID]               INT             NOT NULL,
    [MemberID]               INT             NULL,
    [SportsDetails]          NVARCHAR (2000) NULL,
    [DateCreated]            DATETIME        NULL,
    [DateUpdated]            DATETIME        NULL,
    [CreatedBy]              INT             NULL,
    [UpdatedBy]              INT             NULL,
    [SportsPreferenceTypeID] INT             NULL,
    [SYS_CHANGE_OPERATION]   NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]     BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberSportsDetails_Staging] PRIMARY KEY CLUSTERED ([SportsID] ASC)
);

