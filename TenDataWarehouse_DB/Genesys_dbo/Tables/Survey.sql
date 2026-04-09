CREATE TABLE [Genesys_dbo].[Survey] (
    [IsGroup]            INT              NOT NULL,
    [IsPublished]        INT              NULL,
    [IsTemplate]         INT              NOT NULL,
    [MinAcceptableScore] NUMERIC (18)     NULL,
    [Note]               NVARCHAR (255)   NULL,
    [ParentSurveyId]     VARCHAR (32)     NULL,
    [Priority]           INT              NULL,
    [RankGroupId]        UNIQUEIDENTIFIER NULL,
    [RecordCall]         INT              NULL,
    [SurveyID]           VARCHAR (32)     NOT NULL,
    [SurveyName]         NVARCHAR (255)   NOT NULL,
    [Type]               INT              NULL,
    CONSTRAINT [PK_Genesys_dbo_Survey] PRIMARY KEY CLUSTERED ([SurveyID] ASC)
);

