CREATE TABLE [TenMAID_Global].[CoprorateJobTemplateAdmin_Staging] (
    [CreatedBy]            INT            NULL,
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [TemplateCategoryId]   INT            NULL,
    [TemplateContent]      NVARCHAR (MAX) NULL,
    [TemplateID]           INT            NOT NULL,
    [TemplateName]         VARCHAR (500)  NULL,
    [UpdatedBy]            INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_CoprorateJobTemplateAdmin_Staging] PRIMARY KEY CLUSTERED ([TemplateID] ASC)
);

