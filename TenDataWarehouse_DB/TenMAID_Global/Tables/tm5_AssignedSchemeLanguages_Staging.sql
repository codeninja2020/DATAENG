CREATE TABLE [TenMAID_Global].[tm5_AssignedSchemeLanguages_Staging] (
    [AssignedBy]           INT           NULL,
    [AssignedLang]         VARCHAR (100) NULL,
    [CreateDate]           DATETIME      NULL,
    [DefaultLang]          VARCHAR (50)  NULL,
    [ID]                   INT           NOT NULL,
    [SchemeId]             INT           NULL,
    [UpdateDate]           DATETIME      NULL,
    [UpdatedBy]            INT           NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_AssignedSchemeLanguages_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

