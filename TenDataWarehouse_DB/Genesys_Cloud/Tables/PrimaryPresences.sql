CREATE TABLE [Genesys_Cloud].[PrimaryPresences] (
    [userId]                 NVARCHAR (128) NOT NULL,
    [startTime]              DATETIME2 (7)  NOT NULL,
    [endTime]                DATETIME2 (7)  NOT NULL,
    [systemPresence]         NVARCHAR (128) NOT NULL,
    [organizationPresenceId] NVARCHAR (128) NULL,
    [InsertedOn]             DATETIME       NOT NULL,
    CONSTRAINT [PK_Genesys_Cloud.PrimaryPresences] PRIMARY KEY CLUSTERED ([userId] ASC, [startTime] ASC, [systemPresence] ASC)
);


GO
ALTER TABLE [Genesys_Cloud].[PrimaryPresences] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);

