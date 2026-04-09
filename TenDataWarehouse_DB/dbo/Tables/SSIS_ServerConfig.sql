CREATE TABLE [dbo].[SSIS_ServerConfig] (
    [ServerId]                INT           IDENTITY (1, 1) NOT NULL,
    [ServerName]              VARCHAR (128) NOT NULL,
    [DatabaseName]            VARCHAR (30)  NULL,
    [ConnectionString]        VARCHAR (255) NOT NULL,
    [DestinationDatabaseName] VARCHAR (30)  NULL,
    CONSTRAINT [PK_SSIS_ServerConfig_ServerId] PRIMARY KEY CLUSTERED ([ServerId] ASC),
    CONSTRAINT [UNQ_SSIS_ServerConfig_ServerName] UNIQUE NONCLUSTERED ([ServerName] ASC, [DatabaseName] ASC)
);

