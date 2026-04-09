CREATE TABLE [TenMAID_Global].[tm5_EmployeeLanguageDetails_Staging] (
    [CreatedBy]            INT            NULL,
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [EmployeeID]           INT            NULL,
    [EmployeeLanguageID]   INT            NOT NULL,
    [LanguageCodeID]       NVARCHAR (200) NULL,
    [LanguageLevelID]      INT            NULL,
    [UpdatedBy]            INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_EmployeeLanguageDetails_Staging] PRIMARY KEY CLUSTERED ([EmployeeLanguageID] ASC)
);

