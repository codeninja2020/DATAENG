CREATE TABLE [Genesys_dbo].[SurveyForm] (
    [CallIdKey]      VARCHAR (20)     NOT NULL,
    [Duration]       INT              NULL,
    [IsComplete]     INT              NOT NULL,
    [MaxScore]       NUMERIC (18)     NULL,
    [MinScore]       NUMERIC (18)     NULL,
    [RankName]       NVARCHAR (40)    NULL,
    [Score]          NUMERIC (18)     NULL,
    [SurveyedIntxId] VARCHAR (32)     NULL,
    [SurveyFormId]   UNIQUEIDENTIFIER NOT NULL,
    [SurveyID]       VARCHAR (32)     NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyForm] PRIMARY KEY CLUSTERED ([SurveyFormId] ASC)
);

