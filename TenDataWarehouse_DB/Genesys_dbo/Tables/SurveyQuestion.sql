CREATE TABLE [Genesys_dbo].[SurveyQuestion] (
    [FailSurveyScore]    NUMERIC (18)   NULL,
    [IsOptional]         INT            NOT NULL,
    [IsTemplate]         INT            NOT NULL,
    [MaxScore]           NUMERIC (18)   NOT NULL,
    [MinAcceptableScore] NUMERIC (18)   NOT NULL,
    [MinScore]           NUMERIC (18)   NOT NULL,
    [Options]            NVARCHAR (255) NULL,
    [QuestionName]       NVARCHAR (255) NOT NULL,
    [QuestionParentId]   VARCHAR (32)   NULL,
    [QuestionText]       NVARCHAR (255) NULL,
    [QuestionType]       INT            NOT NULL,
    [Retries]            INT            NULL,
    [Sequence]           INT            NULL,
    [SurveyID]           VARCHAR (32)   NULL,
    [SurveyQuestionID]   VARCHAR (32)   NOT NULL,
    [Timeout]            INT            NULL,
    [Weight]             NUMERIC (18)   NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyQuestion] PRIMARY KEY CLUSTERED ([SurveyQuestionID] ASC)
);

