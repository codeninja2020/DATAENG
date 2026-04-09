CREATE TABLE [TenMAID_US].[CorporateAttachments] (
    [AttachmentID]      INT NOT NULL,
    [CorporateID]       INT NULL,
    [CorporateSchemeID] INT NOT NULL,
    CONSTRAINT [PK_TenMAID_US_CorporateAttachments] PRIMARY KEY CLUSTERED ([AttachmentID] ASC, [CorporateSchemeID] ASC)
);

