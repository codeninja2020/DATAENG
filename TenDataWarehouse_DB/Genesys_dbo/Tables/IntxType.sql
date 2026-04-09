CREATE TABLE [Genesys_dbo].[IntxType] (
    [Admin_Editable] INT           NOT NULL,
    [IntxTypeID]     INT           NOT NULL,
    [Name]           NVARCHAR (30) NOT NULL,
    [Version]        INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IntxType] PRIMARY KEY CLUSTERED ([IntxTypeID] ASC)
);

