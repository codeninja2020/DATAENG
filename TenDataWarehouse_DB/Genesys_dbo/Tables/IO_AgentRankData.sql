CREATE TABLE [Genesys_dbo].[IO_AgentRankData] (
    [AgentGroupDataID]  CHAR (22)      NOT NULL,
    [AgentID]           CHAR (22)      NOT NULL,
    [AgentRankDataID]   CHAR (22)      NOT NULL,
    [CriterionRank]     INT            NULL,
    [DateTimeUTCValue]  DATETIME       NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [NumericValue]      NUMERIC (18)   NULL,
    [Version]           INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AgentRankData] PRIMARY KEY CLUSTERED ([AgentRankDataID] ASC)
);

