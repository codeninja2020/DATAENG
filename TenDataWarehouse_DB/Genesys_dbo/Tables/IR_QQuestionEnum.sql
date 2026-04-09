CREATE TABLE [Genesys_dbo].[IR_QQuestionEnum] (
    [EnumText]    NVARCHAR (255)   NOT NULL,
    [HelpText]    NVARCHAR (1024)  NULL,
    [QQuestionId] UNIQUEIDENTIFIER NOT NULL,
    [Score]       NUMERIC (18)     NOT NULL,
    [Sequence]    INT              NOT NULL,
    [Version]     INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_QQuestionEnum] PRIMARY KEY CLUSTERED ([QQuestionId] ASC, [Sequence] ASC)
);

