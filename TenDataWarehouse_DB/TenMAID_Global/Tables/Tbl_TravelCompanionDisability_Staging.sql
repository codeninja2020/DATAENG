CREATE TABLE [TenMAID_Global].[Tbl_TravelCompanionDisability_Staging] (
    [TravelCompanionDisabilityID]        INT             NOT NULL,
    [CompanionID]                        INT             NULL,
    [MemberID]                           INT             NULL,
    [DisabilityDetails]                  NVARCHAR (1000) NULL,
    [DateCreated]                        DATETIME        NULL,
    [DateUpdated]                        DATETIME        NULL,
    [CreatedBy]                          INT             NULL,
    [UpdatedBy]                          INT             NULL,
    [ForeignTravelCompanionDisabilityID] INT             NULL,
    [SYS_CHANGE_OPERATION]               NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]                 BIGINT          NULL,
    CONSTRAINT [PK_Tbl_TravelCompanionDisability_Staging] PRIMARY KEY CLUSTERED ([TravelCompanionDisabilityID] ASC)
);

