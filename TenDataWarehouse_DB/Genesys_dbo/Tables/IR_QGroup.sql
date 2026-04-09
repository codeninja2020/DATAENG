CREATE TABLE [Genesys_dbo].[IR_QGroup] (
    [GroupName]       NVARCHAR (255)   NOT NULL,
    [IsOptional]      TINYINT          NOT NULL,
    [IsTemplate]      TINYINT          NOT NULL,
    [Note]            NVARCHAR (1024)  NULL,
    [QGroupId]        UNIQUEIDENTIFIER NOT NULL,
    [QuestionnaireId] UNIQUEIDENTIFIER NULL,
    [Sequence]        INT              NOT NULL,
    [Version]         INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_QGroup] PRIMARY KEY CLUSTERED ([QGroupId] ASC)
);

