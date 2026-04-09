CREATE TABLE [TenMAID_Global].[Tbl_MemberCompanionTravelPreference_Staging] (
    [TravelPreferenceID]        INT             NOT NULL,
    [MemberID]                  INT             NULL,
    [CompanionID]               INT             NOT NULL,
    [AirlinePreferences]        NVARCHAR (1000) NULL,
    [ClassOfCabin]              INT             NULL,
    [HotelPreferences]          NVARCHAR (1000) NULL,
    [HomeAirport]               NVARCHAR (100)  NULL,
    [SeatPreferences]           NVARCHAR (1000) NULL,
    [AdditionalInformation]     NVARCHAR (1000) NULL,
    [DateCreated]               DATETIME        NULL,
    [DateUpdated]               DATETIME        NULL,
    [CreatedBy]                 INT             NULL,
    [UpdatedBy]                 INT             NULL,
    [ForeignCompanionID]        INT             NULL,
    [ForeignTravelPreferenceID] INT             NULL,
    [SYS_CHANGE_OPERATION]      NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]        BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberCompanionTravelPreference_Staging] PRIMARY KEY CLUSTERED ([CompanionID] ASC)
);

