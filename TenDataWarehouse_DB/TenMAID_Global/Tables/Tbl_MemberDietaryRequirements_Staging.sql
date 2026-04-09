CREATE TABLE [TenMAID_Global].[Tbl_MemberDietaryRequirements_Staging] (
    [DietaryID]                  INT             NOT NULL,
    [MemberID]                   INT             NOT NULL,
    [DietaryRequirementsDetails] NVARCHAR (2000) NULL,
    [DateCreated]                DATETIME        NULL,
    [DateUpdated]                DATETIME        NULL,
    [CreatedBy]                  INT             NULL,
    [UpdatedBy]                  INT             NULL,
    [SYS_CHANGE_OPERATION]       NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]         BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberDietaryRequirements_Staging] PRIMARY KEY CLUSTERED ([DietaryID] ASC)
);

