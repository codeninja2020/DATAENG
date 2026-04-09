CREATE TABLE [TenMAID_Global].[CorporateAttachment_Staging] (
    [CorporateSchemeID]    INT             NULL,
    [CurrentFileName]      NVARCHAR (200)  NULL,
    [DateCreated]          DATETIME        NULL,
    [Description]          NVARCHAR (1000) NULL,
    [FileExtension]        NVARCHAR (20)   NULL,
    [id]                   INT             NOT NULL,
    [OriginalFileName]     NVARCHAR (200)  NULL,
    [OriginalPath]         VARCHAR (512)   NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_Global_CorporateAttachment_Staging] PRIMARY KEY CLUSTERED ([id] ASC)
);

