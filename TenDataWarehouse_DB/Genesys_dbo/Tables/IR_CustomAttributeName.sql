CREATE TABLE [Genesys_dbo].[IR_CustomAttributeName] (
    [CustomAttributeNameId] INT            NOT NULL,
    [Name]                  NVARCHAR (255) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_CustomAttributeName] PRIMARY KEY CLUSTERED ([CustomAttributeNameId] ASC)
);

