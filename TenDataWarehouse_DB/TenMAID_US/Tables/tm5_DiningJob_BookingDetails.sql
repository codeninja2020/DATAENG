CREATE TABLE [TenMAID_US].[tm5_DiningJob_BookingDetails] (
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
    CONSTRAINT [PK_TenMAID_US_tm5_DiningJob_BookingDetails] PRIMARY KEY CLUSTERED ([RequestId] ASC)
);

