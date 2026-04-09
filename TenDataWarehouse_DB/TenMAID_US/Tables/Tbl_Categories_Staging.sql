CREATE TABLE [TenMAID_US].[Tbl_Categories_Staging] (
    [CategoryID]           INT            NOT NULL,
    [CreatedBy]            INT            NULL,
    [DateCreated]          DATETIME       NULL,
    [DateUpdated]          DATETIME       NULL,
    [DefaultPage]          INT            NULL,
    [Description]          NVARCHAR (200) NULL,
    [IsActive]             BIT            NULL,
    [JobDefinition]        NVARCHAR (MAX) NULL,
    [JobDefinitionExtra]   NVARCHAR (MAX) NULL,
    [Level]                INT            NULL,
    [ParentID]             INT            NULL,
    [UpdatedBy]            INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_Categories_Staging] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

