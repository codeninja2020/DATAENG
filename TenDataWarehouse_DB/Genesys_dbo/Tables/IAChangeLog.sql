CREATE TABLE [Genesys_dbo].[IAChangeLog] (
    [IAChangeLogId]     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ChangeDateTime]    DATETIME       NOT NULL,
    [ChangeDateTimeGMT] DATETIME       NOT NULL,
    [ChangeTime]        CHAR (8)       NOT NULL,
    [ChangeType]        VARCHAR (50)   NOT NULL,
    [EntryClass]        NVARCHAR (50)  NOT NULL,
    [EntryKey]          NVARCHAR (128) NULL,
    [I3TimeStampGMT]    DATETIME       NOT NULL,
    [SiteId]            SMALLINT       NOT NULL,
    [StationId]         NVARCHAR (50)  NOT NULL,
    [SubSiteId]         SMALLINT       NOT NULL,
    [UserId]            NVARCHAR (50)  NULL,
    CONSTRAINT [PK_Genesys_dbo_IAChangeLogId] PRIMARY KEY CLUSTERED ([IAChangeLogId] ASC)
);

