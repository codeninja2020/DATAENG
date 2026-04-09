CREATE TABLE [Genesys_dbo].[IR_KeywordSet] (
    [Category]     NVARCHAR (128) NULL,
    [DisplayName]  NVARCHAR (128) NOT NULL,
    [KeywordSetId] INT            NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_KeywordSet] PRIMARY KEY CLUSTERED ([KeywordSetId] ASC)
);

