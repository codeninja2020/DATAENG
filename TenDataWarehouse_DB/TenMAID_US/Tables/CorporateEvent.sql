CREATE TABLE [TenMAID_US].[CorporateEvent] (
    [CorporateSchemeID] INT             NOT NULL,
    [CreatedBy]         INT             NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [EventTypeID]       INT             NOT NULL,
    [id]                INT             NOT NULL,
    [Notes]             NVARCHAR (2000) NOT NULL,
    CONSTRAINT [PK_TenMAID_US_CorporateEvent] PRIMARY KEY CLUSTERED ([id] ASC)
);

