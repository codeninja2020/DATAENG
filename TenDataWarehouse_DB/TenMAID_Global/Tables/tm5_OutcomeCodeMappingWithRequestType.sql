CREATE TABLE [TenMAID_Global].[tm5_OutcomeCodeMappingWithRequestType] (
    [ContactId]              INT NULL,
    [DependentOutcomeCodeId] INT NULL,
    [InteractionId]          INT NULL,
    [OutcomeCodeId]          INT NULL,
    [OutcomeCodeMappingId]   INT NOT NULL,
    [RequestMappingId]       INT NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_OutcomeCodeMappingWithRequestType] PRIMARY KEY CLUSTERED ([OutcomeCodeMappingId] ASC)
);

