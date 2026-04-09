CREATE TABLE [Genesys_dbo].[LoginLogoutChangeLog] (
    [Action]                   SMALLINT      NOT NULL,
    [ActionDateTime]           DATETIME2 (7) NOT NULL,
    [ActionDateTimeGMT]        DATETIME2 (7) NOT NULL,
    [ActionResult]             NVARCHAR (50) NULL,
    [ApplicationId]            SMALLINT      NOT NULL,
    [I3TimeStampGMT]           DATETIME      NOT NULL,
    [ICServer]                 NVARCHAR (50) NULL,
    [Id]                       INT           NOT NULL,
    [SessionManagerInstanceId] NVARCHAR (50) NULL,
    [SiteId]                   SMALLINT      NOT NULL,
    [Station]                  NVARCHAR (50) NULL,
    [UserId]                   NVARCHAR (50) NULL,
    CONSTRAINT [PK_Genesys_dbo_LoginLogoutChangeLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);

