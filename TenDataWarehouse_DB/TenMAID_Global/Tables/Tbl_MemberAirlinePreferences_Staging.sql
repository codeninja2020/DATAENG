CREATE TABLE [TenMAID_Global].[Tbl_MemberAirlinePreferences_Staging] (
    [AirlinePreferenceID]  INT           NOT NULL,
    [AirlineName]          NVARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_Tbl_MemberAirlinePreferences_Staging] PRIMARY KEY CLUSTERED ([AirlinePreferenceID] ASC)
);

