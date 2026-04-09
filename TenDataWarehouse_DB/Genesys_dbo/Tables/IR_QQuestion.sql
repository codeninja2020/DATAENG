CREATE TABLE [Genesys_dbo].[IR_QQuestion] (
    [CanMarkNA]          TINYINT          NOT NULL,
    [HasCommentField]    TINYINT          NOT NULL,
    [HelpText]           NVARCHAR (1024)  NULL,
    [IsTemplate]         TINYINT          NOT NULL,
    [MaxScore]           NUMERIC (18)     NOT NULL,
    [MinAcceptableScore] NUMERIC (18)     NOT NULL,
    [MinScore]           NUMERIC (18)     NOT NULL,
    [Note]               NVARCHAR (1024)  NULL,
    [QGroupId]           UNIQUEIDENTIFIER NOT NULL,
    [QQuestionId]        UNIQUEIDENTIFIER NOT NULL,
    [QuestionPromptType] SMALLINT         NOT NULL,
    [QuestionText]       NVARCHAR (1024)  NOT NULL,
    [QuestionType]       SMALLINT         NOT NULL,
    [Sequence]           INT              NOT NULL,
    [Version]            INT              NOT NULL,
    [Weight]             NUMERIC (18)     NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_QQuestion] PRIMARY KEY CLUSTERED ([QQuestionId] ASC)
);

