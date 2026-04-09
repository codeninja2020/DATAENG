CREATE TABLE [Genesys_dbo].[IO_AgentScheduleBid] (
    [AgentGroupID]              CHAR (22)      NULL,
    [AgentID]                   CHAR (22)      NOT NULL,
    [AgentRank]                 INT            NOT NULL,
    [AgentScheduleBidID]        CHAR (22)      NOT NULL,
    [LastSubmissionDateTimeUTC] DATETIME       NULL,
    [ModifierUserID]            NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]         DATETIME       NULL,
    [PeerCount]                 INT            NOT NULL,
    [ScheduleBidID]             CHAR (22)      NOT NULL,
    [SubmissionCount]           INT            NOT NULL,
    [Version]                   INT            NOT NULL,
    [XData]                     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AgentScheduleBid] PRIMARY KEY CLUSTERED ([AgentScheduleBidID] ASC)
);

