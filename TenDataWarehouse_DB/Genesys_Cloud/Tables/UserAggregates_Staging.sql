CREATE TABLE [Genesys_Cloud].[UserAggregates_Staging] (
    [userId]               NVARCHAR (128) NOT NULL,
    [intervalUtc]          NVARCHAR (128) NOT NULL,
    [metric]               NVARCHAR (128) NOT NULL,
    [qualifier]            NVARCHAR (128) NOT NULL,
    [intervalStartLocal]   DATETIME       NULL,
    [intervalEndLocal]     DATETIME       NULL,
    [sum]                  FLOAT (53)     NULL,
    [InsertedOn]           DATETIME       DEFAULT (getdate()) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_Genesys_Cloud.UserAggregates_Staging] PRIMARY KEY CLUSTERED ([userId] ASC, [intervalUtc] ASC, [metric] ASC, [qualifier] ASC)
);

