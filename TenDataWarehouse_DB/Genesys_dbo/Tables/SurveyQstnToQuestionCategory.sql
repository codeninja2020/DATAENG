CREATE TABLE [Genesys_dbo].[SurveyQstnToQuestionCategory] (
    [SurveyQuestionCategoryId] VARCHAR (32) NOT NULL,
    [SurveyQuestionId]         VARCHAR (32) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyQstnToQuestionCategory] PRIMARY KEY CLUSTERED ([SurveyQuestionCategoryId] ASC, [SurveyQuestionId] ASC)
);

