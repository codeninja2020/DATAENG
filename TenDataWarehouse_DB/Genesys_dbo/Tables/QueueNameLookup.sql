CREATE TABLE [Genesys_dbo].[QueueNameLookup] (
    [QueueId]   BIGINT         NOT NULL,
    [QueueName] NVARCHAR (250) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_QueueNameLookup] PRIMARY KEY CLUSTERED ([QueueId] ASC)
);

