CREATE TABLE [Sitata].[TravelRestriction] (
    [TravelRestrictionID] INT             IDENTITY (1, 1) NOT NULL,
    [OriginCountryCode]   NVARCHAR (10)   NULL,
    [Comment]             NVARCHAR (MAX)  NULL,
    [Effective_As_Of]     DATETIME2 (7)   NULL,
    [InsertedOn]          DATETIME2 (7)   NULL,
    [Filename]            NVARCHAR (1000) NULL,
    [LanguageCode]        NVARCHAR (10)   NULL,
    [type]                INT             NULL,
    [value]               INT             NULL,
    [vaccinated]          BIT             NULL,
    PRIMARY KEY CLUSTERED ([TravelRestrictionID] ASC)
);

