CREATE TABLE [Genesys_Cloud].[RoutingStatus] (
    [userId]        NVARCHAR (128) NOT NULL,
    [startTime]     DATETIME2 (7)  NOT NULL,
    [endTime]       DATETIME2 (7)  NOT NULL,
    [routingStatus] NVARCHAR (128) NOT NULL,
    [InsertedOn]    DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.RoutingStatus] PRIMARY KEY CLUSTERED ([userId] ASC, [startTime] ASC, [routingStatus] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[RoutingStatus] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

