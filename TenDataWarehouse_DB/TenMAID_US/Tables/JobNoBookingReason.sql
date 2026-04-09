CREATE TABLE [TenMAID_US].[JobNoBookingReason] (
    [JobBookingStatusID]   INT            NULL,
    [JobNoBookingReasonID] INT            NOT NULL,
    [Name]                 NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_TenMAID_US_JobNoBookingReason] PRIMARY KEY CLUSTERED ([JobNoBookingReasonID] ASC)
);

