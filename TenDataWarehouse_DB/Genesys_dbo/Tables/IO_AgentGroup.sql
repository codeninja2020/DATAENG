CREATE TABLE [Genesys_dbo].[IO_AgentGroup] (
    [ActivityBidding]        TINYINT        NULL,
    [AgentGroupID]           CHAR (22)      NOT NULL,
    [AgentGroupName]         NVARCHAR (100) NOT NULL,
    [AgentGroupRank]         INT            NULL,
    [EvaluationStrategy]     TINYINT        NULL,
    [LastRankingDateTimeUTC] DATETIME       NULL,
    [ModifierUserID]         NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]      DATETIME       NULL,
    [NewRandomNumberOnSave]  TINYINT        NULL,
    [PreferenceToCoverage]   TINYINT        NULL,
    [RankAgentsOnSave]       TINYINT        NULL,
    [ScheduleBidding]        TINYINT        NULL,
    [SchedulingUnitID]       CHAR (22)      NOT NULL,
    [Version]                INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AgentGroup] PRIMARY KEY CLUSTERED ([AgentGroupID] ASC)
);

