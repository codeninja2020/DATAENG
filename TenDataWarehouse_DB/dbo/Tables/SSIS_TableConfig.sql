CREATE TABLE [dbo].[SSIS_TableConfig] (
    [TableId]                 INT           IDENTITY (1, 1) NOT NULL,
    [ServerId]                INT           NOT NULL,
    [TableName]               VARCHAR (500) NOT NULL,
    [SchemaName]              VARCHAR (50)  NOT NULL,
    [LoadType]                CHAR (1)      NOT NULL,
    [IsClusteredColumnStore]  BIT           NOT NULL,
    [Enabled]                 BIT           NULL,
    [SSISApplicationId]       INT           NULL,
    [InsertedOn]              DATETIME      CONSTRAINT [DF_SSIS_TableConfig_DATETIME] DEFAULT (getdate()) NOT NULL,
    [IsChangeTrackingEnabled] BIT           NOT NULL,
    [NewSchemaName]           VARCHAR (100) NULL,
    [ChangeTrackingVersion]   BIGINT        NULL,
    CONSTRAINT [PK_SSIS_TableConfig_TableId] PRIMARY KEY CLUSTERED ([TableId] ASC),
    CONSTRAINT [CK_SSIS_TableConfig_LoadType] CHECK ([LoadType]='I' OR [LoadType]='F'),
    CONSTRAINT [FK_SSIS_TableConfig] FOREIGN KEY ([ServerId]) REFERENCES [dbo].[SSIS_ServerConfig] ([ServerId]),
    CONSTRAINT [UNQ_SSIS_TableConfig_ServerId_TableName_SchemaName] UNIQUE NONCLUSTERED ([ServerId] ASC, [TableName] ASC, [SchemaName] ASC)
);

