CREATE TABLE [Genesys_dbo].[ConnSubType] (
    [Admin_Editable] INT           NOT NULL,
    [ConnSubTypeId]  INT           NOT NULL,
    [InsertionOrder] INT           NOT NULL,
    [Name]           NVARCHAR (30) NULL,
    [Version]        INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_ConnSubType] PRIMARY KEY CLUSTERED ([ConnSubTypeId] ASC)
);

