CREATE TABLE [Genesys_dbo].[ConnectionType] (
    [Admin_Editable] INT           NOT NULL,
    [ConnTypeID]     INT           NOT NULL,
    [Name]           NVARCHAR (30) NOT NULL,
    [Version]        INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_ConnectionType] PRIMARY KEY CLUSTERED ([ConnTypeID] ASC)
);

