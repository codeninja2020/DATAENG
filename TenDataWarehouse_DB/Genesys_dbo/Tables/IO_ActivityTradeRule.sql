CREATE TABLE [Genesys_dbo].[IO_ActivityTradeRule] (
    [ActivityTradeAction] INT             NOT NULL,
    [ActivityTradeRuleID] CHAR (22)       NOT NULL,
    [ActivityTypeID]      CHAR (22)       NOT NULL,
    [ModifierUserID]      NVARCHAR (100)  NULL,
    [ModifyDateTimeUTC]   DATETIME        NULL,
    [RequireAdminReview]  TINYINT         NOT NULL,
    [SchedulingUnitID]    CHAR (22)       NOT NULL,
    [ShowAgentWarning]    TINYINT         NOT NULL,
    [Version]             INT             NOT NULL,
    [WarningMessage]      NVARCHAR (2000) NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_ActivityTradeRule] PRIMARY KEY CLUSTERED ([ActivityTradeRuleID] ASC)
);

