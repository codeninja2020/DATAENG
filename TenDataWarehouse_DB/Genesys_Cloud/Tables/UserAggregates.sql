CREATE TABLE [Genesys_Cloud].[UserAggregates] (
    [userId]             NVARCHAR (128) NOT NULL,
    [intervalUtc]        NVARCHAR (128) NOT NULL,
    [metric]             NVARCHAR (128) NOT NULL,
    [qualifier]          NVARCHAR (128) NOT NULL,
    [intervalStartLocal] DATETIME       NOT NULL,
    [intervalEndLocal]   DATETIME       NOT NULL,
    [sum]                FLOAT (53)     NULL,
    [InsertedOn]         DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.UserAggregates] PRIMARY KEY CLUSTERED ([userId] ASC, [intervalUtc] ASC, [metric] ASC, [qualifier] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[UserAggregates] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

