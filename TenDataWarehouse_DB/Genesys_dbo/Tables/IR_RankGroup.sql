CREATE TABLE [Genesys_dbo].[IR_RankGroup] (
    [GroupName]   NVARCHAR (60)    NOT NULL,
    [RankGroupId] UNIQUEIDENTIFIER NOT NULL,
    [Version]     INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_RankGroup] PRIMARY KEY CLUSTERED ([RankGroupId] ASC)
);

