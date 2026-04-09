CREATE TABLE [Genesys_dbo].[IAAttributeLog] (
    [AttributeName]         NVARCHAR (100)  NULL,
    [EnhancedIAChangeLogId] INT             NOT NULL,
    [IAAttributeLogId]      INT             NOT NULL,
    [NewValue]              NVARCHAR (1850) NULL,
    [PreviousValue]         NVARCHAR (1850) NULL,
    CONSTRAINT [PK_Genesys_dbo_IAAttributeLog] PRIMARY KEY CLUSTERED ([IAAttributeLogId] ASC)
);

