CREATE TABLE [TenMAID_Global].[tm5_AssignedSchemeLanguages] (
    [AssignedBy]   INT           NULL,
    [AssignedLang] VARCHAR (100) NULL,
    [CreateDate]   DATETIME      NULL,
    [DefaultLang]  VARCHAR (50)  NULL,
    [ID]           INT           NOT NULL,
    [SchemeId]     INT           NULL,
    [UpdateDate]   DATETIME      NULL,
    [UpdatedBy]    INT           NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_AssignedSchemeLanguages] PRIMARY KEY CLUSTERED ([ID] ASC)
);

