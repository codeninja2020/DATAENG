CREATE TABLE [Genesys_dbo].[IR_RankDefn] (
    [RankGroupId] UNIQUEIDENTIFIER NOT NULL,
    [RankId]      UNIQUEIDENTIFIER NOT NULL,
    [RankName]    NVARCHAR (40)    NOT NULL,
    [RankPct]     NUMERIC (18)     NOT NULL,
    [Version]     INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_RankDefn] PRIMARY KEY CLUSTERED ([RankId] ASC)
);

