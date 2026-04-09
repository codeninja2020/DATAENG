CREATE TABLE [TenMAID_US].[Tm5_NPSTemplateSendTracking] (
    [EventID]                       INT       NULL,
    [ID]                            INT       NOT NULL,
    [JobID]                         INT       NULL,
    [LangaugeID]                    CHAR (10) NULL,
    [MemberID]                      INT       NULL,
    [RequestTypeId]                 INT       NULL,
    [SendBy]                        INT       NULL,
    [SendOn]                        DATETIME  NULL,
    [TemplateTypeID]                INT       NULL,
    [Tm5_NPSTemplateSendTrackingId] INT       IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_TenMAID_US_Tm5_NPSTemplateSendTrackingId] PRIMARY KEY CLUSTERED ([Tm5_NPSTemplateSendTrackingId] ASC)
);

