CREATE TABLE [TenMAID_US].[Language] (
    [Description] NVARCHAR (200) NOT NULL,
    [LanguageID]  NVARCHAR (5)   NOT NULL,
    [LCID]        INT            NULL,
    [Name]        NVARCHAR (50)  NULL,
    CONSTRAINT [PK_TenMAID_US_Language] PRIMARY KEY CLUSTERED ([LanguageID] ASC)
);

