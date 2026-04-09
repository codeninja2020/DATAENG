CREATE TABLE [Genesys_dbo].[SurveyRule] (
    [AttributeId]  VARCHAR (50)   NULL,
    [DateValue]    DATETIME       NULL,
    [IntegerValue] INT            NULL,
    [Operand]      INT            NOT NULL,
    [RuleID]       VARCHAR (32)   NOT NULL,
    [RuleType]     INT            NULL,
    [StringValue]  NVARCHAR (512) NULL,
    [SurveyID]     VARCHAR (32)   NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_SurveyRule] PRIMARY KEY CLUSTERED ([RuleID] ASC)
);

