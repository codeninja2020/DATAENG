CREATE TABLE [Genesys_dbo].[SurveyPrompt] (
    [PromptName]     NVARCHAR (255)  NULL,
    [PromptText]     NVARCHAR (1024) NULL,
    [PromptType]     INT             NOT NULL,
    [RecordingFile]  NVARCHAR (255)  NULL,
    [SurveyPromptID] VARCHAR (32)    NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyPrompt] PRIMARY KEY CLUSTERED ([SurveyPromptID] ASC)
);

