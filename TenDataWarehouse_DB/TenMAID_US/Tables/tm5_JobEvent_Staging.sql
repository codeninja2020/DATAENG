CREATE TABLE [TenMAID_US].[tm5_JobEvent_Staging] (
    [CloseRequest]                  BIT             NULL,
    [CreatedBy]                     INT             NULL,
    [DateCreated]                   DATETIME        NULL,
    [EventId]                       INT             NOT NULL,
    [FeedbackType]                  INT             NULL,
    [isSaved]                       BIT             NULL,
    [JobContact]                    INT             NULL,
    [JobId]                         INT             NULL,
    [JobInteractionWith]            INT             NULL,
    [JobNoBookingReason]            NVARCHAR (50)   NULL,
    [MemberSurveyID]                INT             NULL,
    [Notes]                         NVARCHAR (4000) NULL,
    [OutcomeCodeId]                 INT             NULL,
    [ReferenceEventIDforattachemnt] INT             NULL,
    [SourceJobId]                   INT             NULL,
    [TaskId]                        INT             NULL,
    [TimeSpent]                     FLOAT (53)      NULL,
    [TurnaroundDateTime]            DATETIME        NULL,
    [SYS_CHANGE_OPERATION]          NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]            BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_JobEvent_Staging] PRIMARY KEY CLUSTERED ([EventId] ASC)
);

