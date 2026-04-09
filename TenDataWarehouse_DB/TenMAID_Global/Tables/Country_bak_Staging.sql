CREATE TABLE [TenMAID_Global].[Country_bak_Staging] (
    [Description]          NVARCHAR (200) NULL,
    [ISO_CountryID]        NCHAR (2)      NOT NULL,
    [Name]                 NVARCHAR (50)  NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_Country_bak_Staging] PRIMARY KEY CLUSTERED ([ISO_CountryID] ASC)
);

