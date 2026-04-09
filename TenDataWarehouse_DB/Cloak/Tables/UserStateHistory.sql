CREATE TABLE [Cloak].[UserStateHistory] (
    [AcquiringConnectorID] INT      NOT NULL,
    [CHID]                 INT      NULL,
    [ConnectorID]          INT      NOT NULL,
    [DBDuration]           INT      NULL,
    [Duration]             REAL     NOT NULL,
    [EndTime]              DATETIME NOT NULL,
    [GroupID]              INT      NOT NULL,
    [ID]                   INT      NOT NULL,
    [Index]                INT      NOT NULL,
    [QueueID]              INT      NOT NULL,
    [ReasonCode]           INT      NOT NULL,
    [SessionID]            INT      NOT NULL,
    [SiteID]               INT      NULL,
    [StartTime]            DATETIME NOT NULL,
    [State]                INT      NOT NULL,
    [TaskID]               INT      NOT NULL,
    [Team]                 INT      NOT NULL,
    CONSTRAINT [PK_Cloak_UserStateHistory] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_State_INC]
    ON [Cloak].[UserStateHistory]([State] ASC, [SessionID] ASC)
    INCLUDE([EndTime], [QueueID], [ReasonCode], [StartTime]);

