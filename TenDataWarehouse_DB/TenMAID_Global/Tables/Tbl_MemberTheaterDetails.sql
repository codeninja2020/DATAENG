CREATE TABLE [TenMAID_Global].[Tbl_MemberTheaterDetails] (
    [TheaterID]           INT             NOT NULL,
    [MemberID]            INT             NULL,
    [TheaterDetails]      NVARCHAR (2000) NULL,
    [DateCreated]         DATETIME        NULL,
    [DateUpdated]         DATETIME        NULL,
    [CreatedBy]           INT             NULL,
    [UpdatedBy]           INT             NULL,
    [TheaterPreferenceID] INT             NULL,
    [ForeignTheaterID]    INT             NULL,
    CONSTRAINT [PK_Tbl_MemberTheaterDetails] PRIMARY KEY CLUSTERED ([TheaterID] ASC)
);

