CREATE TABLE [TenMAID_Global].[CoprorateJobTemplateAdmin] (
    [CreatedBy]          INT            NULL,
    [DateCreated]        DATETIME       NULL,
    [DateUpdated]        DATETIME       NULL,
    [TemplateCategoryId] INT            NULL,
    [TemplateContent]    NVARCHAR (MAX) NULL,
    [TemplateID]         INT            NOT NULL,
    [TemplateName]       VARCHAR (500)  NULL,
    [UpdatedBy]          INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_CoprorateJobTemplateAdmin] PRIMARY KEY CLUSTERED ([TemplateID] ASC)
);

