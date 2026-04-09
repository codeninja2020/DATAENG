CREATE TABLE [TenMAID_US].[Tm5_NPSTemplateSendTracking_Staging] (
    [EventID]              INT          NULL,
    [ID]                   INT          NULL,
    [JobID]                INT          NULL,
    [LangaugeID]           CHAR (10)    NULL,
    [MemberID]             INT          NULL,
    [RequestTypeId]        INT          NULL,
    [SendBy]               INT          NULL,
    [SendOn]               DATETIME     NULL,
    [TemplateTypeID]       INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL
);

