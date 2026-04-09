CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionDisability] (
    [TravelCompanionDisabilityID]        INT             NOT NULL,
    [CompanionID]                        INT             NULL,
    [MemberID]                           INT             NULL,
    [DisabilityDetails]                  NVARCHAR (1000) NULL,
    [DateCreated]                        DATETIME        NULL,
    [DateUpdated]                        DATETIME        NULL,
    [CreatedBy]                          INT             NULL,
    [UpdatedBy]                          INT             NULL,
    [ForeignTravelCompanionDisabilityID] INT             NULL,
    CONSTRAINT [PK_Tbl_TravelCompanionDisability] PRIMARY KEY CLUSTERED ([TravelCompanionDisabilityID] ASC)
);

