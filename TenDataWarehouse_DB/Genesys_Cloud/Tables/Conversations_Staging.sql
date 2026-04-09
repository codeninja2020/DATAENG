CREATE TABLE [Genesys_Cloud].[Conversations_Staging] (
    [conversationId]       NVARCHAR (128) NOT NULL,
    [conversationStart]    DATETIME       NULL,
    [conversationEnd]      DATETIME       NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_dbo.Conversations_Staging] PRIMARY KEY CLUSTERED ([conversationId] ASC)
);

