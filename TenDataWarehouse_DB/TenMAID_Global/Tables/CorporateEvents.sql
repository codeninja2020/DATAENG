CREATE TABLE [TenMAID_Global].[CorporateEvents] (
    [CorporateID]       INT NULL,
    [CorporateSchemeID] INT NOT NULL,
    [EventID]           INT NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_CorporateEvents] PRIMARY KEY CLUSTERED ([EventID] ASC, [CorporateSchemeID] ASC)
);

