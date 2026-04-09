CREATE TABLE [dbo].[zzSSIS_TableConfig_Bck_2023-08-29] (
    [TableId]                 INT           IDENTITY (1, 1) NOT NULL,
    [ServerId]                INT           NOT NULL,
    [TableName]               VARCHAR (500) NOT NULL,
    [SchemaName]              VARCHAR (50)  NOT NULL,
    [LoadType]                CHAR (1)      NOT NULL,
    [IsClusteredColumnStore]  BIT           NOT NULL,
    [Enabled]                 BIT           NULL,
    [SSISApplicationId]       INT           NULL,
    [InsertedOn]              DATETIME      NOT NULL,
    [IsChangeTrackingEnabled] BIT           NOT NULL,
    [NewSchemaName]           VARCHAR (100) NULL,
    [ChangeTrackingVersion]   BIGINT        NULL
);

