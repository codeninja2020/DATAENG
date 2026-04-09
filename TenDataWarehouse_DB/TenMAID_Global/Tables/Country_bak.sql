CREATE TABLE [TenMAID_Global].[Country_bak] (
    [Description]   NVARCHAR (200) NOT NULL,
    [ISO_CountryID] NCHAR (2)      NOT NULL,
    [Name]          NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_Country_bak] PRIMARY KEY CLUSTERED ([ISO_CountryID] ASC)
);

