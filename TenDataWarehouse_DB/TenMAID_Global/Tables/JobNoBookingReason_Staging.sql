CREATE TABLE [TenMAID_Global].[JobNoBookingReason_Staging] (
    [JobBookingStatusID]   INT            NULL,
    [JobNoBookingReasonID] INT            NOT NULL,
    [Name]                 NVARCHAR (100) NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_JobNoBookingReason_Staging] PRIMARY KEY CLUSTERED ([JobNoBookingReasonID] ASC)
);

