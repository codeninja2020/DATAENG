CREATE TABLE [Genesys_dbo].[ININSearch] (
    [CreatorUserId] NVARCHAR (50)    NULL,
    [FolderId]      UNIQUEIDENTIFIER NULL,
    [IsFolder]      TINYINT          NULL,
    [IsPublic]      TINYINT          NULL,
    [SearchId]      UNIQUEIDENTIFIER NOT NULL,
    [SearchTarget]  VARCHAR (50)     NULL,
    [SearchTitle]   NVARCHAR (255)   NULL,
    CONSTRAINT [PK_Genesys_dbo_ININSearch] PRIMARY KEY CLUSTERED ([SearchId] ASC)
);

