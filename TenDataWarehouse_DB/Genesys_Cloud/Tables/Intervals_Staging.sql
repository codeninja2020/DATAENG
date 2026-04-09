CREATE TABLE [Genesys_Cloud].[Intervals_Staging] (
    [IntervalType]         INT          NOT NULL,
    [LastIntervalUtc]      DATETIME     NULL,
    [InsertedOn]           DATETIME     DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_dbo.Intervals_Staging] PRIMARY KEY CLUSTERED ([IntervalType] ASC)
);

