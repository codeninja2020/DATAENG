CREATE TABLE [TenMAID_US].[tm5_OutcomeCodes_Staging] (
    [CompletionBarValue]   INT           NULL,
    [OutcomeCodeId]        INT           NOT NULL,
    [OutcomeName]          VARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)  NULL,
    [SYS_CHANGE_VERSION]   BIGINT        NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_OutcomeCodes_Staging] PRIMARY KEY CLUSTERED ([OutcomeCodeId] ASC)
);

