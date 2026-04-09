CREATE TABLE [Genesys_dbo].[OrgType] (
    [Admin_Editable] INT           NOT NULL,
    [Name]           NVARCHAR (20) NOT NULL,
    [OrgTypeID]      INT           NOT NULL,
    [Version]        INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_OrgType] PRIMARY KEY CLUSTERED ([OrgTypeID] ASC)
);

