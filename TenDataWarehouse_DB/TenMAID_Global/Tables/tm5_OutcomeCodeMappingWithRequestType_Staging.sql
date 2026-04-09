CREATE TABLE [TenMAID_Global].[tm5_OutcomeCodeMappingWithRequestType_Staging] (
    [ContactId]              INT          NULL,
    [DependentOutcomeCodeId] INT          NULL,
    [InteractionId]          INT          NULL,
    [OutcomeCodeId]          INT          NULL,
    [OutcomeCodeMappingId]   INT          NOT NULL,
    [RequestMappingId]       INT          NULL,
    [SYS_CHANGE_OPERATION]   NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]     BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_OutcomeCodeMappingWithRequestType_Staging] PRIMARY KEY CLUSTERED ([OutcomeCodeMappingId] ASC)
);

