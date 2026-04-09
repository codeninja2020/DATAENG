CREATE TABLE [Genesys_dbo].[IO_Changes] (
    [ChangeSet] VARCHAR (MAX) NULL,
    [MID]       CHAR (22)     NULL,
    [PK]        INT           NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_Changes] PRIMARY KEY CLUSTERED ([PK] ASC)
);

