CREATE TABLE [Genesys_Cloud].[RoutingStatus_Staging] (
    [userId]               NVARCHAR (128) NOT NULL,
    [startTime]            DATETIME2 (7)  NOT NULL,
    [endTime]              DATETIME2 (7)  NULL,
    [routingStatus]        NVARCHAR (128) NOT NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_Genesys_Cloud.RoutingStatus_Staging] PRIMARY KEY CLUSTERED ([userId] ASC, [startTime] ASC, [routingStatus] ASC)
);

