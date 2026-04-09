CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionAllergy_Staging] (
    [TravelCompanionAllergyID]        INT             NOT NULL,
    [CompanionID]                     INT             NULL,
    [MemberID]                        INT             NULL,
    [AllergyDetails]                  NVARCHAR (1000) NULL,
    [DateCreated]                     DATETIME        NULL,
    [DateUpdated]                     DATETIME        NULL,
    [CreatedBy]                       INT             NULL,
    [UpdatedBy]                       INT             NULL,
    [ForeignTravelCompanionAllergyID] INT             NULL,
    [SYS_CHANGE_OPERATION]            NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]              BIGINT          NULL,
    CONSTRAINT [PK_Tbl_TravelCompanionAllergy_Staging] PRIMARY KEY CLUSTERED ([TravelCompanionAllergyID] ASC) WITH (FILLFACTOR = 90)
);

