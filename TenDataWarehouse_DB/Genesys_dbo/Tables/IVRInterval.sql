CREATE TABLE [Genesys_dbo].[IVRInterval] (
    [cExitPath]         NVARCHAR (250) NOT NULL,
    [cLevelName]        NVARCHAR (50)  NOT NULL,
    [dIntervalStart]    DATETIME       NOT NULL,
    [dIntervalStartGMT] DATETIME       NOT NULL,
    [I3TimeStampGMT]    DATETIME       NOT NULL,
    [IVRIntervalId]     INT            NOT NULL,
    [nDuration]         INT            NOT NULL,
    [nDurationFirst]    INT            NOT NULL,
    [nDurationRepeat]   INT            NOT NULL,
    [nEnteredFirst]     INT            NOT NULL,
    [nEnteredRepeat]    INT            NOT NULL,
    [nExitCode]         INT            NOT NULL,
    [nLevel]            TINYINT        NOT NULL,
    [ParentLevels]      NVARCHAR (200) NOT NULL,
    [SiteId]            SMALLINT       NOT NULL,
    [SubSiteId]         SMALLINT       NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IVRInterval] PRIMARY KEY CLUSTERED ([IVRIntervalId] ASC, [SiteId] ASC)
);

