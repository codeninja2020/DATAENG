CREATE TABLE [Genesys_dbo].[UserWorkgroups] (
    [UserWorkgroupsId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [I3TimeStampGMT]   DATETIME      NOT NULL,
    [QueueFlag]        TINYINT       NOT NULL,
    [SiteId]           SMALLINT      NOT NULL,
    [SubSiteId]        SMALLINT      NOT NULL,
    [UserId]           NVARCHAR (50) NULL,
    [WorkGroup]        NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_UserWorkgroups] PRIMARY KEY CLUSTERED ([UserWorkgroupsId] ASC)
);

