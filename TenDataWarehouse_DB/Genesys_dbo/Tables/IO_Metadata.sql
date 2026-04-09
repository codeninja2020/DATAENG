CREATE TABLE [Genesys_dbo].[IO_Metadata] (
    [key]           VARCHAR (MAX) NULL,
    [value]         VARCHAR (MAX) NULL,
    [IO_MetadataId] INT           IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_Metadata] PRIMARY KEY CLUSTERED ([IO_MetadataId] ASC)
);

