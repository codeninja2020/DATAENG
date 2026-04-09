CREATE TABLE [TenMAID_Global].[Tbl_MemberMusicDetails] (
    [MusicID]           INT             NOT NULL,
    [MemberID]          INT             NULL,
    [MusicDetails]      NVARCHAR (2000) NULL,
    [DateCreated]       DATETIME        NULL,
    [DateUpdated]       DATETIME        NULL,
    [CreatedBy]         INT             NULL,
    [UpdatedBy]         INT             NULL,
    [MusicPreferenceID] INT             NULL,
    [ForeignMusicID]    INT             NULL,
    CONSTRAINT [PK_Tbl_MemberMusicDetails] PRIMARY KEY CLUSTERED ([MusicID] ASC)
);

