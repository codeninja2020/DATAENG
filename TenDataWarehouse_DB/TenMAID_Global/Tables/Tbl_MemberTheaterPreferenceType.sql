CREATE TABLE [TenMAID_Global].[Tbl_MemberTheaterPreferenceType] (
    [TheaterPreferenceID]   INT            NOT NULL,
    [TheaterPreferenceType] NVARCHAR (100) NULL,
    [IsActive]              BIT            NULL,
    CONSTRAINT [PK_Tbl_MemberTheaterPreferenceType] PRIMARY KEY CLUSTERED ([TheaterPreferenceID] ASC)
);

