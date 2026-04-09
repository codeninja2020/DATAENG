CREATE TABLE [Genesys_dbo].[flowexec_Storage] (
    [CreateHost] NVARCHAR (128)   NOT NULL,
    [CreateTime] DATETIME2 (7)    NOT NULL,
    [LastHost]   NVARCHAR (128)   NOT NULL,
    [LastTime]   DATETIME2 (7)    NOT NULL,
    [StorageID]  UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_flowexec_Storage] PRIMARY KEY CLUSTERED ([StorageID] ASC)
);

