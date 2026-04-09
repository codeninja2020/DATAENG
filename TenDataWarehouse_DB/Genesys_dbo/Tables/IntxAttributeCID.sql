CREATE TABLE [Genesys_dbo].[IntxAttributeCID] (
    [ConversationAttribute] NVARCHAR (4000) NULL,
    [ConversationID]        CHAR (39)       NOT NULL,
    [EventDateTime]         DATETIME2 (7)   NOT NULL,
    [ExtID]                 NVARCHAR (256)  NULL,
    [Intx_Part_ID]          CHAR (22)       NOT NULL,
    [IntxID]                CHAR (22)       NOT NULL,
    [Version]               INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IntxAttributeCID] PRIMARY KEY CLUSTERED ([ConversationID] ASC, [Intx_Part_ID] ASC, [IntxID] ASC)
);

