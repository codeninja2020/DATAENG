CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionTravelProfile_Staging] (
    [TravelCompanionProfileID]        INT             NOT NULL,
    [MemberID]                        INT             NULL,
    [CompanionID]                     INT             NULL,
    [Company]                         NVARCHAR (100)  NULL,
    [LevelofLoyalty]                  NVARCHAR (100)  NULL,
    [CardNumber]                      NVARCHAR (100)  NULL,
    [DateCreated]                     DATETIME        NULL,
    [DateUpdated]                     DATETIME        NULL,
    [CreatedBy]                       INT             NULL,
    [UpdatedBy]                       INT             NULL,
    [Username]                        NVARCHAR (200)  NULL,
    [Password]                        NVARCHAR (510)  NULL,
    [Notes]                           NVARCHAR (1000) NULL,
    [ForeignTravelCompanionProfileID] INT             NULL,
    [SYS_CHANGE_OPERATION]            NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]              BIGINT          NULL,
    CONSTRAINT [PK_Tbl_TravelCompanionTravelProfile_Staging] PRIMARY KEY CLUSTERED ([TravelCompanionProfileID] ASC)
);

