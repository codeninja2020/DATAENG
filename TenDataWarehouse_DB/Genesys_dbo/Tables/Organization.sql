CREATE TABLE [Genesys_dbo].[Organization] (
    [Active]         TINYINT        NOT NULL,
    [AppOrgID]       NVARCHAR (255) NULL,
    [ExtID]          NVARCHAR (255) NULL,
    [ExtSource]      NVARCHAR (64)  NULL,
    [IsPrivate]      TINYINT        NOT NULL,
    [ModifyDateTime] DATETIME2 (7)  NULL,
    [Name]           NVARCHAR (100) NOT NULL,
    [OrgID]          CHAR (22)      NOT NULL,
    [OrgTypeID]      INT            NULL,
    [OwnerID]        NVARCHAR (50)  NULL,
    [SiteID]         SMALLINT       NULL,
    [UnknownIndivID] CHAR (22)      NULL,
    [Version]        INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_Organization] PRIMARY KEY CLUSTERED ([OrgID] ASC)
);

