CREATE TABLE [TenMAID_Global].[Tbl_MemberActivitiesandExperiencesPreferencesDetails_Staging] (
    [ActivityID]                      INT             NOT NULL,
    [MemberID]                        INT             NULL,
    [ActivitiesandExperiencesDetails] NVARCHAR (2000) NULL,
    [DateCreated]                     DATETIME        NULL,
    [DateUpdated]                     DATETIME        NULL,
    [CreatedBy]                       INT             NULL,
    [UpdatedBy]                       INT             NULL,
    [ForeignActivityID]               INT             NULL,
    [SYS_CHANGE_OPERATION]            NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]              BIGINT          NULL,
    CONSTRAINT [PK_Tbl_MemberActivitiesandExperiencesPreferencesDetails_Staging] PRIMARY KEY CLUSTERED ([ActivityID] ASC)
);

