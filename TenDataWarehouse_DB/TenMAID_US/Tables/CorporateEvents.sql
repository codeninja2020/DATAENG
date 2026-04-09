CREATE TABLE [TenMAID_US].[CorporateEvents] (
    [CorporateID]       INT NULL,
    [CorporateSchemeID] INT NOT NULL,
    [EventID]           INT NOT NULL,
    CONSTRAINT [PK_TenMAID_US_CorporateEvents] PRIMARY KEY CLUSTERED ([EventID] ASC, [CorporateSchemeID] ASC)
);

