CREATE TABLE [TenMAID_Global].[Tbl_MemberMusicPreferenceType] (
    [MusicPreferenceID]   INT           NOT NULL,
    [MusicPreferenceType] VARCHAR (100) NULL,
    [IsActive]            BIT           NULL,
    CONSTRAINT [PK_Tbl_MemberMusicPreferenceType] PRIMARY KEY CLUSTERED ([MusicPreferenceID] ASC)
);

