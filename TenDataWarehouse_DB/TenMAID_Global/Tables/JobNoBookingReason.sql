CREATE TABLE [TenMAID_Global].[JobNoBookingReason] (
    [JobBookingStatusID]   INT            NULL,
    [JobNoBookingReasonID] INT            NOT NULL,
    [Name]                 NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_TenMAID_Global_JobNoBookingReason] PRIMARY KEY CLUSTERED ([JobNoBookingReasonID] ASC)
);

