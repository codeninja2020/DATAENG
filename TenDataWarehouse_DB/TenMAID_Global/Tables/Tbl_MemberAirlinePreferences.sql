CREATE TABLE [TenMAID_Global].[Tbl_MemberAirlinePreferences] (
    [AirlinePreferenceID] INT           NOT NULL,
    [AirlineName]         NVARCHAR (50) NULL,
    CONSTRAINT [PK_Tbl_MemberAirlinePreferences] PRIMARY KEY CLUSTERED ([AirlinePreferenceID] ASC)
);

