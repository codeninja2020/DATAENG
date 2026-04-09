CREATE TABLE [TenMAID_Global].[Tbl_MemberSportsDetails] (
    [SportsID]               INT             NOT NULL,
    [MemberID]               INT             NULL,
    [SportsDetails]          NVARCHAR (2000) NULL,
    [DateCreated]            DATETIME        NULL,
    [DateUpdated]            DATETIME        NULL,
    [CreatedBy]              INT             NULL,
    [UpdatedBy]              INT             NULL,
    [SportsPreferenceTypeID] INT             NULL,
    CONSTRAINT [PK_Tbl_MemberSportsDetails] PRIMARY KEY CLUSTERED ([SportsID] ASC)
);

