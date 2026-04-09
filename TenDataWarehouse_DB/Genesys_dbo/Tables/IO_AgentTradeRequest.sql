CREATE TABLE [Genesys_dbo].[IO_AgentTradeRequest] (
    [AgentID]                CHAR (22)      NULL,
    [AgentTradeRequestID]    CHAR (22)      NOT NULL,
    [ExpirationTimeUTC]      DATETIME       NOT NULL,
    [MaxEndTimeOfferedUTC]   DATETIME       NOT NULL,
    [MaxStartTimeOfferedUTC] DATETIME       NOT NULL,
    [MinEndTimeOfferedUTC]   DATETIME       NOT NULL,
    [MinStartTimeOfferedUTC] DATETIME       NOT NULL,
    [ModifierUserID]         NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]      DATETIME       NULL,
    [SubmittedDateTimeUTC]   DATETIME       NOT NULL,
    [TradeRequestState]      INT            NOT NULL,
    [Version]                INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AgentTradeRequest] PRIMARY KEY CLUSTERED ([AgentTradeRequestID] ASC)
);

