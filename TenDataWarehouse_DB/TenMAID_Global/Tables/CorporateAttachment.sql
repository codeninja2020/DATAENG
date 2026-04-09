CREATE TABLE [TenMAID_Global].[CorporateAttachment] (
    [CorporateSchemeID] INT             NOT NULL,
    [CurrentFileName]   NVARCHAR (200)  NULL,
    [DateCreated]       DATETIME        NULL,
    [Description]       NVARCHAR (1000) NULL,
    [FileExtension]     NVARCHAR (20)   NULL,
    [id]                INT             NOT NULL,
    [OriginalFileName]  NVARCHAR (200)  NULL,
    [OriginalPath]      VARCHAR (512)   NULL,
    CONSTRAINT [PK_TenMAID_Global_CorporateAttachment] PRIMARY KEY CLUSTERED ([id] ASC)
);

