CREATE TABLE [Genesys_ININ_DIALER_40].[CallHistory_Details] (
    [callhistory_id]     BIGINT    NOT NULL,
    [callidkey]          CHAR (18) NULL,
    [call_requested]     DATETIME  NULL,
    [line_connect]       DATETIME  NULL,
    [ca_requested]       DATETIME  NULL,
    [ca_begin]           DATETIME  NULL,
    [ca_end]             DATETIME  NULL,
    [acd_routed]         DATETIME  NULL,
    [agent_connected]    DATETIME  NULL,
    [playback_requested] DATETIME  NULL,
    [insert_time]        DATETIME  NULL
);

