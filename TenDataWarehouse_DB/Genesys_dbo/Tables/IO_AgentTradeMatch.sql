CREATE TABLE [Genesys_dbo].[IO_AgentTradeMatch] (
    [AgentTradeMatchID]      CHAR (22)      NOT NULL,
    [GainedEndTimeUTC]       DATETIME       NOT NULL,
    [GainedStartTimeUTC]     DATETIME       NOT NULL,
    [ModifierUserID]         NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]      DATETIME       NULL,
    [TiedTradeRequestID]     CHAR (22)      NOT NULL,
    [TradedAwayEndTimeUTC]   DATETIME       NOT NULL,
    [TradedAwayStartTimeUTC] DATETIME       NOT NULL,
    [TradeDenyReason]        INT            NULL,
    [TradeMatchState]        INT            NOT NULL,
    [TradingAgentID]         CHAR (22)      NOT NULL,
    [Version]                INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AgentTradeMatch] PRIMARY KEY CLUSTERED ([AgentTradeMatchID] ASC)
);

