CREATE TABLE [dbo].[SSIS_DataTypeMapping] (
    [SSIS_DataTypeMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [SQLDataType]            VARCHAR (100) NOT NULL,
    [CSharpDataType]         VARCHAR (100) NULL,
    [SSISDataType]           VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([SSIS_DataTypeMappingId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SSIS_DataTypeMapping_SQLDataType]
    ON [dbo].[SSIS_DataTypeMapping]([SQLDataType] ASC);

