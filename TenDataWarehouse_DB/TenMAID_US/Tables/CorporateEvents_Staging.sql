CREATE TABLE [TenMAID_US].[CorporateEvents_Staging] (
    [CorporateID]          INT          NULL,
    [CorporateSchemeID]    INT          NOT NULL,
    [EventID]              INT          NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_US_CorporateEvents_Staging] PRIMARY KEY CLUSTERED ([EventID] ASC, [CorporateSchemeID] ASC)
);

