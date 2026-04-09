CREATE TABLE [Genesys_dbo].[IO_AgentGroupData] (
    [AgentGroupDataID]  CHAR (22)      NOT NULL,
    [AgentGroupID]      CHAR (22)      NOT NULL,
    [Ascending]         TINYINT        NOT NULL,
    [CriterionFormat]   INT            NOT NULL,
    [CriterionName]     NVARCHAR (100) NOT NULL,
    [ModifierUserID]    NVARCHAR (100) NULL,
    [ModifyDateTimeUTC] DATETIME       NULL,
    [Version]           INT            NOT NULL,
    [Weight]            TINYINT        NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_AgentGroupData] PRIMARY KEY CLUSTERED ([AgentGroupDataID] ASC)
);

