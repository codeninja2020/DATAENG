CREATE TABLE [Genesys_dbo].[IO_AgentDataVersion] (
    [AccrualVersion]        INT       NOT NULL,
    [AgentID]               CHAR (22) NOT NULL,
    [AllotmentVersion]      INT       NOT NULL,
    [ScheduleVersion]       INT       NOT NULL,
    [TimeOffRequestVersion] INT       NOT NULL,
    [TradeRequestVersion]   INT       NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AgentDataVersion] PRIMARY KEY CLUSTERED ([AgentID] ASC)
);

