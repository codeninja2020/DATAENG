CREATE TABLE [Cloak].[ReasonCodes] (
    [CreateDate]               DATETIME     NOT NULL,
    [DeleteDate]               DATETIME     NULL,
    [Description]              VARCHAR (50) NOT NULL,
    [ModifiedBy]               INT          NULL,
    [ReasonCodeID]             INT          NOT NULL,
    [SiteID]                   INT          NULL,
    [SystemValue]              INT          NULL,
    [TimeInStateAlertPoint]    INT          NOT NULL,
    [TimeInStateRedAlertPoint] INT          NOT NULL,
    [Value]                    INT          NOT NULL,
    CONSTRAINT [PK_Cloak_ReasonCodes] PRIMARY KEY CLUSTERED ([ReasonCodeID] ASC)
);

