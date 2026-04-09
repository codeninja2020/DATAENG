CREATE TABLE [TenMAID_Global].[tm5_EmployeeLanguageDetails] (
    [CreatedBy]          INT            NULL,
    [DateCreated]        DATETIME       NULL,
    [DateUpdated]        DATETIME       NULL,
    [EmployeeID]         INT            NULL,
    [EmployeeLanguageID] INT            NOT NULL,
    [LanguageCodeID]     NVARCHAR (200) NULL,
    [LanguageLevelID]    INT            NULL,
    [UpdatedBy]          INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_EmployeeLanguageDetails] PRIMARY KEY CLUSTERED ([EmployeeLanguageID] ASC)
);

