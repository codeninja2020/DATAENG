CREATE TABLE [Sitata].[EntryRequirement] (
    [EntryRequirementID]          INT             IDENTITY (1, 1) NOT NULL,
    [OriginCountryCode]           NVARCHAR (10)   NOT NULL,
    [affectedCountryCode]         NVARCHAR (10)   NOT NULL,
    [afectedCountry_Sec_Emer_Num] NVARCHAR (2048) NULL,
    [Comment]                     NVARCHAR (MAX)  NULL,
    [Quarantine_Days]             INT             NULL,
    [Entry_Hours]                 INT             NULL,
    [Effective_As_Of]             DATETIME2 (7)   NULL,
    [Filename]                    NVARCHAR (1000) NULL,
    [InsertedOn]                  DATETIME2 (7)   NULL,
    [LanguageCode]                NVARCHAR (10)   NULL,
    [type]                        INT             NULL,
    [value]                       INT             NULL,
    [vaccinated]                  BIT             NULL,
    PRIMARY KEY CLUSTERED ([EntryRequirementID] ASC)
);

