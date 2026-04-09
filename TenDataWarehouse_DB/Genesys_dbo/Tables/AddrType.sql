CREATE TABLE [Genesys_dbo].[AddrType] (
    [AddrTypeId]     INT           NOT NULL,
    [Admin_Editable] INT           NOT NULL,
    [InsertionOrder] INT           NOT NULL,
    [Name]           NVARCHAR (30) NULL,
    [Version]        INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_AddrType] PRIMARY KEY CLUSTERED ([AddrTypeId] ASC)
);

