CREATE TABLE [TenMAID_US].[tm5_OutcomeCodes] (
    [CompletionBarValue] INT           NULL,
    [OutcomeCodeId]      INT           NOT NULL,
    [OutcomeName]        VARCHAR (100) NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_OutcomeCodes] PRIMARY KEY CLUSTERED ([OutcomeCodeId] ASC)
);

