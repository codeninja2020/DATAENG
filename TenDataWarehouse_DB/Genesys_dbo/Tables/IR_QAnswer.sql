CREATE TABLE [Genesys_dbo].[IR_QAnswer] (
    [IsMarkedNA]   TINYINT          NOT NULL,
    [QAnswerId]    UNIQUEIDENTIFIER NOT NULL,
    [QFormId]      UNIQUEIDENTIFIER NOT NULL,
    [QQuestionId]  UNIQUEIDENTIFIER NOT NULL,
    [RawAnswer]    NVARCHAR (1024)  NULL,
    [Score]        NUMERIC (18)     NULL,
    [Sequence]     INT              NOT NULL,
    [UserComments] NVARCHAR (1024)  NULL,
    [Version]      INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_QAnswer] PRIMARY KEY CLUSTERED ([QAnswerId] ASC)
);

