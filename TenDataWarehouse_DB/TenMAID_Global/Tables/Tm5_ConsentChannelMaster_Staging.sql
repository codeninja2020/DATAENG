CREATE TABLE [TenMAID_Global].[Tm5_ConsentChannelMaster_Staging] (
    [ChannelID]            INT           NULL,
    [ChannelName]          NVARCHAR (50) NULL,
    [ID]                   INT           NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_Tm5_ConsentChannelMaster_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

