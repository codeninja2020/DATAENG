CREATE TABLE [Genesys_dbo].[SurveyUserObjectSecurity] (
    [ExtObjectID]    VARCHAR (32)   NOT NULL,
    [IndivID]        CHAR (22)      NOT NULL,
    [ObjectID]       INT            NULL,
    [ObjectName]     NVARCHAR (255) NULL,
    [ObjectType]     INT            NOT NULL,
    [SiteIdentifier] INT            NOT NULL,
    [UserRight]      INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyUserObjectSecurity] PRIMARY KEY CLUSTERED ([ExtObjectID] ASC, [IndivID] ASC, [ObjectType] ASC, [SiteIdentifier] ASC)
);

