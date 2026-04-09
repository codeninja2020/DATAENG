CREATE TABLE [Genesys_dbo].[IO_VolumeForecastStats] (
    [ACWComplete]              INT            NOT NULL,
    [AverageACWTimeInSeconds]  FLOAT (53)     NULL,
    [AverageTalkTimeInSeconds] FLOAT (53)     NULL,
    [Completed]                INT            NOT NULL,
    [Duration]                 INT            NOT NULL,
    [InteractionType]          INT            NOT NULL,
    [IntervalStartUTC]         DATETIME       NOT NULL,
    [ModifierUserID]           NVARCHAR (100) NULL,
    [ModifyDateTimeUTC]        DATETIME       NULL,
    [NumberACW]                INT            NOT NULL,
    [NumberOfInteractions]     FLOAT (53)     NULL,
    [Offered]                  INT            NOT NULL,
    [SiteID]                   INT            NULL,
    [SkillSet]                 NVARCHAR (255) NOT NULL,
    [TalkCompleteACD]          INT            NOT NULL,
    [Version]                  INT            NOT NULL,
    [VolumeForecastID]         CHAR (22)      NOT NULL,
    [VolumeForecastStatsID]    CHAR (22)      NOT NULL,
    [WorkgroupName]            NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IO_VolumeForecastStats] PRIMARY KEY CLUSTERED ([VolumeForecastStatsID] ASC)
);

