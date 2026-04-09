CREATE TABLE [dbo].[SSIS_ColumnConfig] (
    [ColumnId]          INT           IDENTITY (1, 1) NOT NULL,
    [TableId]           INT           NOT NULL,
    [ColumnName]        VARCHAR (500) NOT NULL,
    [DataType]          VARCHAR (50)  NOT NULL,
    [IsNullable]        BIT           NULL,
    [MaxLength]         INT           NULL,
    [IsPrimary]         BIT           NOT NULL,
    [IsEncrypted]       BIT           NOT NULL,
    [PrimaryKeyOrdinal] TINYINT       NULL,
    CONSTRAINT [PK_SSIS_ColumnConfig_ColumnId] PRIMARY KEY CLUSTERED ([ColumnId] ASC),
    CONSTRAINT [FK_SSIS_ColumnConfig] FOREIGN KEY ([TableId]) REFERENCES [dbo].[SSIS_TableConfig] ([TableId]),
    CONSTRAINT [UNQ_SSIS_ColumnConfig_TableId_ColumnName] UNIQUE NONCLUSTERED ([TableId] ASC, [ColumnName] ASC)
);

