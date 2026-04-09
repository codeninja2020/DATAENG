CREATE TABLE [Genesys_dbo].[SurveyAnswer] (
    [EnumSequence]      INT              NULL,
    [FreeFormAnswerURI] VARCHAR (255)    NULL,
    [NumericScore]      NUMERIC (18)     NULL,
    [SurveyAnswerId]    VARCHAR (32)     NOT NULL,
    [SurveyFormID]      UNIQUEIDENTIFIER NOT NULL,
    [SurveyQuestionId]  VARCHAR (32)     NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyAnswer] PRIMARY KEY CLUSTERED ([SurveyAnswerId] ASC)
);

