CREATE TABLE [TenMAID_Global].[tm5_JobEvent] (
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
    CONSTRAINT [PK_TenMAID_Global_tm5_JobEvent] PRIMARY KEY CLUSTERED ([EventId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SourceJobId_DateCreated_TurnaroundDateTime_INC]
    ON [TenMAID_Global].[tm5_JobEvent]([SourceJobId] ASC, [DateCreated] ASC, [TurnaroundDateTime] ASC)
    INCLUDE([JobContact], [JobId], [OutcomeCodeId]);


GO
CREATE NONCLUSTERED INDEX [IX_tm5_JobEvent_DateCreated]
    ON [TenMAID_Global].[tm5_JobEvent]([DateCreated] ASC, [JobInteractionWith] ASC)
    INCLUDE([JobId]);

