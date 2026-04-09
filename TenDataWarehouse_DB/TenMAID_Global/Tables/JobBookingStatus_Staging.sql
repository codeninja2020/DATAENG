CREATE TABLE [TenMAID_Global].[JobBookingStatus_Staging] (
    [CompletionBarValue]   INT            NULL,
    [JobBookingStatusID]   INT            NOT NULL,
    [JobInteractionType]   INT            NULL,
    [Name]                 NVARCHAR (100) NULL,
    [OrderByColumn]        INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_JobBookingStatus_Staging] PRIMARY KEY CLUSTERED ([JobBookingStatusID] ASC)
);

