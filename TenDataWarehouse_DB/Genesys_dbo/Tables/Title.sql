CREATE TABLE [Genesys_dbo].[Title] (
    [Admin_Editable] INT           NOT NULL,
    [Name]           NVARCHAR (20) NOT NULL,
    [TitleID]        INT           NOT NULL,
    [Version]        INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_Title] PRIMARY KEY CLUSTERED ([TitleID] ASC)
);

