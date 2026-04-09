CREATE TABLE [TenMAID_Global].[Tbl_MemberHotelPreferences] (
    [HotelPreferenceID] INT            NOT NULL,
    [HotelPreference]   NVARCHAR (100) NULL,
    CONSTRAINT [PK_Tbl_MemberHotelPreferences] PRIMARY KEY CLUSTERED ([HotelPreferenceID] ASC)
);

