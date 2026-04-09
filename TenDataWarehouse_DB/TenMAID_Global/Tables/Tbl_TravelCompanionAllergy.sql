CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionAllergy] (
    [TravelCompanionAllergyID]        INT             NOT NULL,
    [CompanionID]                     INT             NULL,
    [MemberID]                        INT             NULL,
    [AllergyDetails]                  NVARCHAR (1000) NULL,
    [DateCreated]                     DATETIME        NULL,
    [DateUpdated]                     DATETIME        NULL,
    [CreatedBy]                       INT             NULL,
    [UpdatedBy]                       INT             NULL,
    [ForeignTravelCompanionAllergyID] INT             NULL,
    CONSTRAINT [PK_Tbl_TravelCompanionAllergy] PRIMARY KEY CLUSTERED ([TravelCompanionAllergyID] ASC) WITH (FILLFACTOR = 90)
);

