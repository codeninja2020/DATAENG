CREATE TABLE [Genesys_dbo].[AttributeType] (
    [Admin_Editable] INT             NOT NULL,
    [AppliesTo]      INT             NOT NULL,
    [AttrTypeID]     INT             NOT NULL,
    [LegalValues]    NVARCHAR (2000) NULL,
    [Name]           NVARCHAR (50)   NOT NULL,
    [ShowIfEmpty]    TINYINT         NOT NULL,
    [Version]        INT             NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_AttributeType] PRIMARY KEY CLUSTERED ([AttrTypeID] ASC)
);

