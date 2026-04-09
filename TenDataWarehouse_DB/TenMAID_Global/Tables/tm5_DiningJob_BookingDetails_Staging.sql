CREATE TABLE [TenMAID_Global].[tm5_DiningJob_BookingDetails_Staging] (
    [BookingDateNotSpecified] BIT          NULL,
    [CreatedBy]               INT          NULL,
    [DateCreated]             DATETIME     NULL,
    [DateModified]            DATETIME     NULL,
    [DateOfBooking]           DATETIME     NULL,
    [EarliestStartTime]       VARCHAR (10) NULL,
    [JobId]                   INT          NULL,
    [JobTypeId]               INT          NULL,
    [LatestStartTime]         VARCHAR (10) NULL,
    [ModifiedBy]              INT          NULL,
    [PartySize]               INT          NULL,
    [PartySizeNotSpecified]   BIT          NULL,
    [RequestId]               INT          NOT NULL,
    [responseDueBy]           DATETIME     NULL,
    [SpecialOccasion]         INT          NULL,
    [SpecialOccasionOthers]   VARCHAR (50) NULL,
    [SYS_CHANGE_OPERATION]    NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]      BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_DiningJob_BookingDetails_Staging] PRIMARY KEY CLUSTERED ([RequestId] ASC)
);

