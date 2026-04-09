CREATE TABLE [Genesys_dbo].[IR_QDirectory] (
    [IsTemplate]     TINYINT          NOT NULL,
    [Note]           NVARCHAR (1024)  NULL,
    [QDirectoryId]   UNIQUEIDENTIFIER NOT NULL,
    [QDirectoryName] NVARCHAR (255)   NULL,
    [Version]        INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_QDirectory] PRIMARY KEY CLUSTERED ([QDirectoryId] ASC)
);

