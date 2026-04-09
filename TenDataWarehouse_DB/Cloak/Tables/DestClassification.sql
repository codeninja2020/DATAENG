CREATE TABLE [Cloak].[DestClassification] (
    [Compare]     VARCHAR (255) NOT NULL,
    [CreateDate]  DATETIME      NOT NULL,
    [DeleteDate]  DATETIME      NULL,
    [Description] VARCHAR (255) NOT NULL,
    [ID]          INT           NOT NULL,
    [ModifiedBy]  INT           NULL,
    [Name]        VARCHAR (300) NULL,
    CONSTRAINT [PK_Cloak_DestClassification] PRIMARY KEY CLUSTERED ([ID] ASC)
);

