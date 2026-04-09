CREATE TABLE [TenMAID_Global].[CardType] (
    [CardTypeDesc] NVARCHAR (50) NULL,
    [CardTypeID]   INT           NOT NULL,
    [CardTypeText] NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_CardType] PRIMARY KEY CLUSTERED ([CardTypeID] ASC)
);

