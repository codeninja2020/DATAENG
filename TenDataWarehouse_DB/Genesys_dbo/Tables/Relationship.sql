CREATE TABLE [Genesys_dbo].[Relationship] (
    [Active]             TINYINT       NOT NULL,
    [DestinationID]      CHAR (22)     NOT NULL,
    [DestinationType]    INT           NOT NULL,
    [ExpirationDateTime] DATETIME2 (7) NULL,
    [ModifyDateTime]     DATETIME2 (7) NULL,
    [RelDescID]          INT           NULL,
    [RelID]              INT           NOT NULL,
    [SiteID]             SMALLINT      NULL,
    [SourceID]           CHAR (22)     NOT NULL,
    [SourceType]         INT           NOT NULL,
    [Version]            INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_Relationship] PRIMARY KEY CLUSTERED ([RelID] ASC)
);

