CREATE TABLE [Genesys_dbo].[IPA_Jobs] (
    [EndDateTime]         DATETIME2 (7)    NULL,
    [EndDateTimeOffset]   INT              NULL,
    [JobExecID]           UNIQUEIDENTIFIER NOT NULL,
    [SiteID]              SMALLINT         NOT NULL,
    [StartDateTime]       DATETIME2 (7)    NOT NULL,
    [StartDateTimeOffset] INT              NOT NULL,
    [Version]             INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IPA_Jobs] PRIMARY KEY CLUSTERED ([JobExecID] ASC)
);

