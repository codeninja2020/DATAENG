CREATE TABLE [TenMAID_Global].[Language_Staging] (
    [Description]          NVARCHAR (200) NULL,
    [LanguageID]           NVARCHAR (5)   NOT NULL,
    [LCID]                 INT            NULL,
    [Name]                 NVARCHAR (50)  NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Language_Staging] PRIMARY KEY CLUSTERED ([LanguageID] ASC)
);

