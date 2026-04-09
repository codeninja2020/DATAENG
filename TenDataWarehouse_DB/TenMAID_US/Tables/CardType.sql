CREATE TABLE [TenMAID_US].[CardType] (
    [CardTypeDesc] NVARCHAR (50) NULL,
    [CardTypeID]   INT           NOT NULL,
    [CardTypeText] NVARCHAR (20) NOT NULL,
    CONSTRAINT [PK_TenMAID_US_CardType] PRIMARY KEY CLUSTERED ([CardTypeID] ASC)
);

