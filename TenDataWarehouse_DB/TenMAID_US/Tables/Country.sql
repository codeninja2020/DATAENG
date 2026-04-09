CREATE TABLE [TenMAID_US].[Country] (
    [Capital]             NVARCHAR (255) NULL,
    [Comment]             NVARCHAR (255) NULL,
    [CountryCode]         INT            NULL,
    [CountryId]           INT            NOT NULL,
    [Currency]            NVARCHAR (255) NULL,
    [CurrencyCode]        NVARCHAR (255) NULL,
    [Description]         NVARCHAR (255) NULL,
    [EU]                  BIT            NULL,
    [FIPS104]             NVARCHAR (255) NULL,
    [Internet]            NVARCHAR (255) NULL,
    [ISO_CountryID]       NVARCHAR (255) NOT NULL,
    [ISO3]                NVARCHAR (255) NULL,
    [ISON]                FLOAT (53)     NULL,
    [MapReference]        NVARCHAR (255) NULL,
    [Name]                NVARCHAR (255) NULL,
    [NationalityPlural]   NVARCHAR (255) NULL,
    [NationalitySingular] NVARCHAR (255) NULL,
    [Population]          FLOAT (53)     NULL,
    [Title]               NVARCHAR (255) NULL,
    CONSTRAINT [PK_TenMAID_US_Country] PRIMARY KEY CLUSTERED ([CountryId] ASC)
);

