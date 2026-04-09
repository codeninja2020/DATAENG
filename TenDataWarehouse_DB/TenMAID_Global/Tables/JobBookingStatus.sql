CREATE TABLE [TenMAID_Global].[JobBookingStatus] (
    [CompletionBarValue] INT            NULL,
    [JobBookingStatusID] INT            NOT NULL,
    [JobInteractionType] INT            NULL,
    [Name]               NVARCHAR (100) NOT NULL,
    [OrderByColumn]      INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_JobBookingStatus] PRIMARY KEY CLUSTERED ([JobBookingStatusID] ASC)
);

