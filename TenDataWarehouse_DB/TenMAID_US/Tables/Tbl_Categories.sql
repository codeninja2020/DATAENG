CREATE TABLE [TenMAID_US].[Tbl_Categories] (
    [CategoryID]         INT            NOT NULL,
    [CreatedBy]          INT            NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [DefaultPage]        INT            NULL,
    [Description]        NVARCHAR (200) NOT NULL,
    [IsActive]           BIT            NULL,
    [JobDefinition]      NVARCHAR (MAX) NULL,
    [JobDefinitionExtra] NVARCHAR (MAX) NULL,
    [Level]              INT            NOT NULL,
    [ParentID]           INT            NULL,
    [UpdatedBy]          INT            NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_Categories] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);

