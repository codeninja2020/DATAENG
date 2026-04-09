CREATE TABLE [Genesys_dbo].[IR_Questionnaire] (
    [IsActive]                  TINYINT          NOT NULL,
    [IsLocked]                  TINYINT          NOT NULL,
    [IsTemplate]                TINYINT          NOT NULL,
    [MaxScore]                  NUMERIC (18)     NULL,
    [MinAcceptableScore]        NUMERIC (18)     NULL,
    [MinScore]                  NUMERIC (18)     NULL,
    [Note]                      NVARCHAR (1024)  NULL,
    [QDirectoryId]              UNIQUEIDENTIFIER NOT NULL,
    [QuestionnaireId]           UNIQUEIDENTIFIER NOT NULL,
    [QuestionnaireName]         NVARCHAR (255)   NOT NULL,
    [RankGroupId]               UNIQUEIDENTIFIER NULL,
    [ShowPassFailWhileScoring]  TINYINT          NOT NULL,
    [ShowRankWhileScoring]      TINYINT          NOT NULL,
    [TotalNumCriticalQuestions] INT              NOT NULL,
    [Version]                   INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_Questionnaire] PRIMARY KEY CLUSTERED ([QuestionnaireId] ASC)
);

