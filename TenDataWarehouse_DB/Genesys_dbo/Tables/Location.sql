CREATE TABLE [Genesys_dbo].[Location] (
    [Active]         TINYINT        NOT NULL,
    [AppLocID]       NVARCHAR (255) NULL,
    [ExtID]          NVARCHAR (255) NULL,
    [ExtSource]      NVARCHAR (64)  NULL,
    [IsPrivate]      TINYINT        NOT NULL,
    [LocID]          CHAR (22)      NOT NULL,
    [ModifyDateTime] DATETIME2 (7)  NULL,
    [Name]           NVARCHAR (100) NULL,
    [OrgID]          CHAR (22)      NULL,
    [OwnerID]        NVARCHAR (50)  NULL,
    [SiteID]         SMALLINT       NULL,
    [UnknownIndivID] CHAR (22)      NULL,
    [Version]        INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_Location] PRIMARY KEY CLUSTERED ([LocID] ASC)
);

