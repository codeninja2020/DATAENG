CREATE TABLE [Genesys_dbo].[SurveyWork] (
    [Data]      NVARCHAR (255)   NULL,
    [ItemID]    UNIQUEIDENTIFIER NOT NULL,
    [SessionID] VARCHAR (32)     NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyWork] PRIMARY KEY CLUSTERED ([ItemID] ASC, [SessionID] ASC)
);

