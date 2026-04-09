CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionDietary_Staging] (
    [TravelCompanionDietaryID]        INT             NOT NULL,
    [CompanionID]                     INT             NULL,
    [MemberID]                        INT             NULL,
    [DietaryRequirementsDetails]      NVARCHAR (1000) NULL,
    [DateCreated]                     DATETIME        NULL,
    [DateUpdated]                     DATETIME        NULL,
    [CreatedBy]                       INT             NULL,
    [UpdatedBy]                       INT             NULL,
    [ForeignTravelCompanionDietaryID] INT             NULL,
    [SYS_CHANGE_OPERATION]            NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]              BIGINT          NULL,
    CONSTRAINT [PK_Tbl_TravelCompanionDietary_Staging] PRIMARY KEY CLUSTERED ([TravelCompanionDietaryID] ASC) WITH (FILLFACTOR = 90)
);

