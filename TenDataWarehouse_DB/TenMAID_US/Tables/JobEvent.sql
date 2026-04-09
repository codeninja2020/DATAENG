CREATE TABLE [TenMAID_US].[JobEvent] (
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
    CONSTRAINT [PK_TenMAID_US_JobEvent] PRIMARY KEY CLUSTERED ([JobID] ASC, [EventID] ASC)
);

