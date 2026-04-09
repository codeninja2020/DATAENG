CREATE TABLE [TenMAID_US].[Country_bak] (
    [Description]   NVARCHAR (200) NOT NULL,
    [ISO_CountryID] NCHAR (2)      NOT NULL,
    [Name]          NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Country_bak] PRIMARY KEY CLUSTERED ([ISO_CountryID] ASC)
);

