CREATE TABLE [TenMAID_Global].[Tbl_MemberDietaryRequirements] (
    [DietaryID]                  INT             NOT NULL,
    [MemberID]                   INT             NOT NULL,
    [DietaryRequirementsDetails] NVARCHAR (2000) NULL,
    [DateCreated]                DATETIME        NULL,
    [DateUpdated]                DATETIME        NULL,
    [CreatedBy]                  INT             NULL,
    [UpdatedBy]                  INT             NULL,
    CONSTRAINT [PK_Tbl_MemberDietaryRequirements] PRIMARY KEY CLUSTERED ([DietaryID] ASC)
);

