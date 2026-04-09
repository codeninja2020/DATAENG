CREATE TABLE [TenMAID_Global].[CardType_Staging] (
    [CardTypeDesc]         NVARCHAR (50) NULL,
    [CardTypeID]           INT           NOT NULL,
    [CardTypeText]         NVARCHAR (20) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_Global_CardType_Staging] PRIMARY KEY CLUSTERED ([CardTypeID] ASC)
);

