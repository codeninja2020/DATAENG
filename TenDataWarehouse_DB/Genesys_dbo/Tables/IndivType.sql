CREATE TABLE [Genesys_dbo].[IndivType] (
    [Admin_Editable] INT           NOT NULL,
    [IndivTypeID]    INT           NOT NULL,
    [Name]           NVARCHAR (30) NOT NULL,
    [Version]        INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IndivType] PRIMARY KEY CLUSTERED ([IndivTypeID] ASC)
);

