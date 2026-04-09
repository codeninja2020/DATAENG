CREATE TABLE [Genesys_dbo].[SurveyQuestionBranching] (
    [Operand1Value]             INT              NULL,
    [Operand2Value]             INT              NULL,
    [OperatorType]              INT              NULL,
    [Sequence]                  INT              NULL,
    [SurveyQuestionBranchingID] UNIQUEIDENTIFIER NOT NULL,
    [SurveyQuestionID]          VARCHAR (32)     NOT NULL,
    [TargetQuestionID]          VARCHAR (32)     NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyQuestionBranching] PRIMARY KEY CLUSTERED ([SurveyQuestionBranchingID] ASC)
);

