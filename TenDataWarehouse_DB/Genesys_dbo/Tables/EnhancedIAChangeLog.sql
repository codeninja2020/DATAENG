CREATE TABLE [Genesys_dbo].[EnhancedIAChangeLog] (
    [ApplicationID]         SMALLINT       NOT NULL,
    [ChangeDateTime]        DATETIME       NOT NULL,
    [ChangeDateTimeGMT]     DATETIME       NOT NULL,
    [ChangeTime]            NCHAR (8)      NOT NULL,
    [ChangeType]            NVARCHAR (50)  NOT NULL,
    [EnhancedIAChangeLogId] INT            NOT NULL,
    [EntryClass]            NVARCHAR (50)  NOT NULL,
    [EntryKey]              NVARCHAR (128) NOT NULL,
    [I3TimeStampGMT]        DATETIME       NOT NULL,
    [SiteId]                SMALLINT       NOT NULL,
    [StationId]             NVARCHAR (50)  NOT NULL,
    [SubSiteId]             SMALLINT       NOT NULL,
    [UserId]                NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_EnhancedIAChangeLog] PRIMARY KEY CLUSTERED ([EnhancedIAChangeLogId] ASC)
);

