CREATE TABLE [TenMAID_Global].[Tbl_MemberActivitiesandExperiencesPreferencesDetails] (
    [ActivityID]                      INT             NOT NULL,
    [MemberID]                        INT             NULL,
    [ActivitiesandExperiencesDetails] NVARCHAR (2000) NULL,
    [DateCreated]                     DATETIME        NULL,
    [DateUpdated]                     DATETIME        NULL,
    [CreatedBy]                       INT             NULL,
    [UpdatedBy]                       INT             NULL,
    [ForeignActivityID]               INT             NULL,
    CONSTRAINT [PK_Tbl_MemberActivitiesandExperiencesPreferencesDetails] PRIMARY KEY CLUSTERED ([ActivityID] ASC)
);

