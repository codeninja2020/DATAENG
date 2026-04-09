CREATE TABLE [Genesys_dbo].[SurveyQuestionEnum] (
    [EnumName]             NVARCHAR (255) NOT NULL,
    [EnumScore]            NUMERIC (18)   NULL,
    [EnumSequence]         INT            NOT NULL,
    [EnumText]             NVARCHAR (255) NULL,
    [SurveyQuestionEnumId] VARCHAR (32)   NOT NULL,
    [SurveyQuestionID]     VARCHAR (32)   NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyQuestionEnum] PRIMARY KEY CLUSTERED ([SurveyQuestionEnumId] ASC)
);

