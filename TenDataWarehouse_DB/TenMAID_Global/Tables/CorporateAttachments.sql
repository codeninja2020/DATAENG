CREATE TABLE [TenMAID_Global].[CorporateAttachments] (
    [AttachmentID]      INT NOT NULL,
    [CorporateID]       INT NULL,
    [CorporateSchemeID] INT NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_CorporateAttachments] PRIMARY KEY CLUSTERED ([AttachmentID] ASC, [CorporateSchemeID] ASC)
);

