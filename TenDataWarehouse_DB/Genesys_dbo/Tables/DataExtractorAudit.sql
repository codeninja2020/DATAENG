CREATE TABLE [Genesys_dbo].[DataExtractorAudit] (
    [CancelledDateTime] DATETIME2 (7)    NULL,
    [CancelledUser]     NVARCHAR (50)    NULL,
    [FailedDateTime]    DATETIME2 (7)    NULL,
    [FailureInfo]       VARCHAR (4000)   NULL,
    [FinishedDateTime]  DATETIME2 (7)    NULL,
    [JobConfig]         NVARCHAR (MAX)   NULL,
    [JobID]             UNIQUEIDENTIFIER NOT NULL,
    [JobName]           NVARCHAR (100)   NOT NULL,
    [OutputFolder]      NVARCHAR (2000)  NULL,
    [QueuedDateTime]    DATETIME2 (7)    NULL,
    [SiteID]            SMALLINT         NOT NULL,
    [StartedDateTime]   DATETIME2 (7)    NULL,
    [SubmitDateTime]    DATETIME2 (7)    NOT NULL,
    [SubmitUser]        NVARCHAR (50)    NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_DataExtractorAudit] PRIMARY KEY CLUSTERED ([JobID] ASC)
);

