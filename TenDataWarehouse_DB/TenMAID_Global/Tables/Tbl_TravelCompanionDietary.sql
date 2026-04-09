CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionDietary] (
    [TravelCompanionDietaryID]        INT             NOT NULL,
    [CompanionID]                     INT             NULL,
    [MemberID]                        INT             NULL,
    [DietaryRequirementsDetails]      NVARCHAR (1000) NULL,
    [DateCreated]                     DATETIME        NULL,
    [DateUpdated]                     DATETIME        NULL,
    [CreatedBy]                       INT             NULL,
    [UpdatedBy]                       INT             NULL,
    [ForeignTravelCompanionDietaryID] INT             NULL,
    CONSTRAINT [PK_Tbl_TravelCompanionDietary] PRIMARY KEY CLUSTERED ([TravelCompanionDietaryID] ASC) WITH (FILLFACTOR = 90)
);

