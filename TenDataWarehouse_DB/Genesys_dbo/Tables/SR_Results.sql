CREATE TABLE [Genesys_dbo].[SR_Results] (
    [EmailAddresses] NVARCHAR (1028) NULL,
    [EmailResult]    NVARCHAR (100)  NULL,
    [EndDateTime]    DATETIME        NULL,
    [FileLocations]  NVARCHAR (1028) NULL,
    [FileResult]     NVARCHAR (100)  NULL,
    [LastUpdate]     DATETIME        NULL,
    [LastUpdatedBy]  NVARCHAR (50)   NULL,
    [Name]           NVARCHAR (100)  NULL,
    [PrinterNames]   NVARCHAR (1028) NULL,
    [PrinterResult]  NVARCHAR (100)  NULL,
    [ReportName]     NVARCHAR (100)  NOT NULL,
    [RunTime]        DATETIME        NULL,
    [SiteName]       NVARCHAR (25)   NOT NULL,
    [StartDateTime]  DATETIME        NULL,
    [TestSchedule]   CHAR (1)        NOT NULL,
    [SR_ResultsId]   INT             IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SR_Results] PRIMARY KEY CLUSTERED ([SR_ResultsId] ASC)
);

