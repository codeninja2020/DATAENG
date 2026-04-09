CREATE TABLE [ivector].[FlightReportWithCabin] (
    [Booking Reference]           NVARCHAR (256) NULL,
    [Job ID]                      NVARCHAR (256) NULL,
    [Flight Booking Reference]    NVARCHAR (256) NULL,
    [Lead Guest Last Name]        NVARCHAR (256) NULL,
    [Market]                      NVARCHAR (256) NULL,
    [Arrival Airport]             NVARCHAR (256) NULL,
    [Booking Date]                DATE           NULL,
    [Departure Aireport]          NVARCHAR (256) NULL,
    [Flight Carrier]              NVARCHAR (256) NULL,
    [Outbound Departure Date]     DATE           NULL,
    [Return Departure Date]       DATE           NULL,
    [Supplier]                    NVARCHAR (256) NULL,
    [Supplier Reference]          NVARCHAR (256) NULL,
    [Geography Level 1]           NVARCHAR (256) NULL,
    [Geography Level 2]           NVARCHAR (256) NULL,
    [Geography Level 3]           NVARCHAR (256) NULL,
    [System User]                 NVARCHAR (256) NULL,
    [Booking Source]              NVARCHAR (256) NULL,
    [Sales Channel]               NVARCHAR (256) NULL,
    [Flight Class]                NVARCHAR (256) NULL,
    [Count]                       INT            NULL,
    [Adults And Children]         INT            NULL,
    [Gross Fare]                  FLOAT (53)     NULL,
    [Total Commission]            FLOAT (53)     NULL,
    [Total Cost]                  FLOAT (53)     NULL,
    [Total Margin]                FLOAT (53)     NULL,
    [Total Passengers]            INT            NULL,
    [Total Price]                 FLOAT (53)     NULL,
    [Total Ticket Amount Payable] FLOAT (53)     NULL,
    [Total Ticket Gross Fare]     FLOAT (53)     NULL,
    [Total Ticket Tax]            FLOAT (53)     NULL,
    [inserted_on]                 DATETIME       NULL,
    [FileName]                    NVARCHAR (255) NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [CIX_JobID]
    ON [ivector].[FlightReportWithCabin];

