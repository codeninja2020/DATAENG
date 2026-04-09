CREATE TABLE [Genesys_Cloud].[PrimaryPresences_Staging] (
    [userId]                 NVARCHAR (128) NOT NULL,
    [startTime]              DATETIME2 (7)  NOT NULL,
    [endTime]                DATETIME2 (7)  NULL,
    [systemPresence]         NVARCHAR (128) NOT NULL,
    [organizationPresenceId] NVARCHAR (128) NULL,
    [InsertedOn]             DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION]   NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]     BIGINT         NULL,
    CONSTRAINT [PK_Genesys_Cloud.PrimaryPresences_Staging] PRIMARY KEY CLUSTERED ([userId] ASC, [startTime] ASC, [systemPresence] ASC)
);

