CREATE TABLE [TenMAID_Global].[Tbl_MemberMusicDetails_Staging] (
    [MusicID]              INT             NOT NULL,
    [MemberID]             INT             NULL,
    [MusicDetails]         NVARCHAR (2000) NULL,
    [DateCreated]          DATETIME        NULL,
    [DateUpdated]          DATETIME        NULL,
    [CreatedBy]            INT             NULL,
    [UpdatedBy]            INT             NULL,
    [MusicPreferenceID]    INT             NULL,
    [ForeignMusicID]       INT             NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberMusicDetails_Staging] PRIMARY KEY CLUSTERED ([MusicID] ASC)
);

