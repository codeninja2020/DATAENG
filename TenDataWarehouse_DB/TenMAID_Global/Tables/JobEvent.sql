CREATE TABLE [TenMAID_Global].[JobEvent] (
    [AttachmentID]       INT           NULL,
    [CompletionBarValue] INT           NULL,
    [DateCreated]        DATETIME      NULL,
    [EventID]            INT           NOT NULL,
    [JobBookingStatus]   INT           NULL,
    [JobCallDirection]   INT           NULL,
    [JobContact]         INT           NULL,
    [JobID]              INT           NOT NULL,
    [JobInteractionWith] INT           NULL,
    [JobNoBookingReason] NVARCHAR (50) NULL,
    [MemberSurveyID]     INT           NULL,
    [TimeSpent]          FLOAT (53)    NULL,
    [TurnaroundDateTime] DATETIME      NULL,
    [TurnaroundOption]   SMALLINT      NULL,
    [TypeOfRequest]      INT           NULL,
    CONSTRAINT [PK_TenMAID_Global_JobEvent] PRIMARY KEY CLUSTERED ([JobID] ASC, [EventID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_DateCreated_JobBookingStatus_INC]
    ON [TenMAID_Global].[JobEvent]([DateCreated] ASC, [JobBookingStatus] ASC)
    INCLUDE([JobContact]);


GO
CREATE NONCLUSTERED INDEX [IX_DateCreated_INC]
    ON [TenMAID_Global].[JobEvent]([DateCreated] ASC, [JobInteractionWith] ASC)
    INCLUDE([EventID], [JobID], [JobBookingStatus], [JobContact], [TurnaroundDateTime], [JobNoBookingReason], [TypeOfRequest]) WITH (DATA_COMPRESSION = PAGE);

