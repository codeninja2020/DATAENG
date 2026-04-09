CREATE TABLE [Genesys_dbo].[SurveyObjectToSurveyPrompt] (
    [AppCode]        INT          NOT NULL,
    [SurveyObjectID] VARCHAR (32) NOT NULL,
    [SurveyPromptID] VARCHAR (32) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyObjectToSurveyPrompt] PRIMARY KEY CLUSTERED ([AppCode] ASC, [SurveyObjectID] ASC, [SurveyPromptID] ASC)
);

