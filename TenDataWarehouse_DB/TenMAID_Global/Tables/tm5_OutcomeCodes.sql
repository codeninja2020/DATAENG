CREATE TABLE [TenMAID_Global].[tm5_OutcomeCodes] (
    [CompletionBarValue] INT           NULL,
    [OutcomeCodeId]      INT           NOT NULL,
    [OutcomeName]        VARCHAR (100) NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_OutcomeCodes] PRIMARY KEY CLUSTERED ([OutcomeCodeId] ASC)
);

