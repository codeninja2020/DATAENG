CREATE TABLE [Django].[member_events_bookings] (
    [id]               INT             NOT NULL,
    [event_id]         INT             NULL,
    [member_id]        INT             NULL,
    [event_date]       DATETIME2 (0)   NULL,
    [booked_timestamp] DATETIME2 (0)   NULL,
    [booking_status]   NVARCHAR (4000) NULL,
    [inserted_on]      DATETIME        NOT NULL,
    [processid]        VARCHAR (255)   NULL
);

