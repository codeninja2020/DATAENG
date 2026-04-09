CREATE TABLE [TenMAID_US].[JobBookingStatus] (
    [CompletionBarValue] INT            NULL,
    [JobBookingStatusID] INT            NOT NULL,
    [JobInteractionType] INT            NULL,
    [Name]               NVARCHAR (100) NOT NULL,
    [OrderByColumn]      INT            NULL,
    CONSTRAINT [PK_TenMAID_US_JobBookingStatus] PRIMARY KEY CLUSTERED ([JobBookingStatusID] ASC)
);

