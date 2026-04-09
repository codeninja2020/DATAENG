CREATE TABLE [Genesys_dbo].[IO_AcceptableTradeStart] (
    [AcceptableTradeStartID] CHAR (22)      NOT NULL,
    [AgentTradeRequestID]    CHAR (22)      NOT NULL,
    [EarliestStartUTC]       DATETIME       NOT NULL,
    [LatestStartUTC]         DATETIME       NOT NULL,
    [ModifierUserID]         NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]      DATETIME       NULL,
    [Version]                INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AcceptableTradeStart] PRIMARY KEY CLUSTERED ([AcceptableTradeStartID] ASC)
);

