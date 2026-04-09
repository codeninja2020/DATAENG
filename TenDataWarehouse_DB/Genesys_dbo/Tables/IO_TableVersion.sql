CREATE TABLE [Genesys_dbo].[IO_TableVersion] (
    [MID]     CHAR (22)    NULL,
    [TableID] INT          NOT NULL,
    [Version] VARCHAR (36) NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_TableVersion] PRIMARY KEY CLUSTERED ([TableID] ASC)
);

