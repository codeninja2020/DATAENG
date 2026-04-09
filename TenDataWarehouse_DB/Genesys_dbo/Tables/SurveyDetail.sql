CREATE TABLE [Genesys_dbo].[SurveyDetail] (
    [CallIdKey]    VARCHAR (20)     NOT NULL,
    [EventCode]    INT              NOT NULL,
    [EventDate]    DATETIME         NOT NULL,
    [EventDetail]  NVARCHAR (255)   NULL,
    [Origin]       INT              NOT NULL,
    [SurveyFormID] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyDetail] PRIMARY KEY CLUSTERED ([SurveyFormID] ASC)
);

