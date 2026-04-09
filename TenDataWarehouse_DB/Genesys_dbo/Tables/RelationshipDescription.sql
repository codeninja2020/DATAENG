CREATE TABLE [Genesys_dbo].[RelationshipDescription] (
    [Active]               TINYINT         NOT NULL,
    [Admin_Editable]       INT             NOT NULL,
    [EligibleDestinations] INT             NOT NULL,
    [EligibleSources]      INT             NOT NULL,
    [InverseName]          NVARCHAR (50)   NOT NULL,
    [ModifyDateTime]       DATETIME2 (7)   NULL,
    [Name]                 NVARCHAR (50)   NOT NULL,
    [RelDescID]            INT             NOT NULL,
    [Remarks]              NVARCHAR (2000) NULL,
    [SiteID]               SMALLINT        NULL,
    [Version]              INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_RelationshipDescription] PRIMARY KEY CLUSTERED ([RelDescID] ASC)
);

