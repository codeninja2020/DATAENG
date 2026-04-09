CREATE TABLE [Genesys_Cloud].[Intervals] (
    [IntervalType]    INT      NOT NULL,
    [LastIntervalUtc] DATETIME NOT NULL,
    [InsertedOn]      DATETIME NOT NULL,
    CONSTRAINT [PK_dbo.Intervals] PRIMARY KEY CLUSTERED ([IntervalType] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[Intervals] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

