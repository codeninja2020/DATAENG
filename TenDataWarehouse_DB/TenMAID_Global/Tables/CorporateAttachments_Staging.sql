CREATE TABLE [TenMAID_Global].[CorporateAttachments_Staging] (
    [AttachmentID]         INT          NOT NULL,
    [CorporateID]          INT          NULL,
    [CorporateSchemeID]    INT          NOT NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_CorporateAttachments_Staging] PRIMARY KEY CLUSTERED ([AttachmentID] ASC, [CorporateSchemeID] ASC)
);

