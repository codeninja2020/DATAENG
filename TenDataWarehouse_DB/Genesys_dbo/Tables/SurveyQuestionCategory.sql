CREATE TABLE [Genesys_dbo].[SurveyQuestionCategory] (
    [ACSISemantics]            INT            NULL,
    [CategoryName]             NVARCHAR (255) NOT NULL,
    [SurveyQuestionCategoryId] VARCHAR (32)   NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyQuestionCategory] PRIMARY KEY CLUSTERED ([SurveyQuestionCategoryId] ASC)
);

