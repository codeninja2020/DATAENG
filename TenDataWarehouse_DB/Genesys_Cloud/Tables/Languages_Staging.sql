CREATE TABLE [Genesys_Cloud].[Languages_Staging] (
    [id]                   NVARCHAR (128) NOT NULL,
    [name]                 NVARCHAR (MAX) NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_dbo.Languages_Staging] PRIMARY KEY CLUSTERED ([id] ASC)
);

