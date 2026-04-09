CREATE TABLE [Cloak].[QueueDefs] (
    [CreateDate]  DATETIME      NOT NULL,
    [DeleteDate]  DATETIME      NULL,
    [Description] VARCHAR (255) NOT NULL,
    [QueueID]     INT           NOT NULL,
    [QueueName]   VARCHAR (100) NULL,
    [QueueType]   INT           NOT NULL,
    CONSTRAINT [PK_Cloak_QueueDefs] PRIMARY KEY CLUSTERED ([QueueID] ASC)
);

