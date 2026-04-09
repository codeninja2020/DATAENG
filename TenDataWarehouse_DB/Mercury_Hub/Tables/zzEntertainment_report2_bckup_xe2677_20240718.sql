CREATE TABLE [Mercury_Hub].[zzEntertainment_report2_bckup_xe2677_20240718] (
    [Entertainment_ReportID]       INT             IDENTITY (1, 1) NOT NULL,
    [redirect_id]                  CHAR (100)      NULL,
    [third_party]                  CHAR (100)      NULL,
    [performance_id]               CHAR (100)      NULL,
    [member_id]                    CHAR (100)      NULL,
    [redirect_timestamp]           DATETIME        NULL,
    [event_id]                     CHAR (100)      NULL,
    [event_name]                   CHAR (600)      NULL,
    [venue_id]                     CHAR (100)      NULL,
    [venue_name]                   CHAR (600)      NULL,
    [start_date]                   DATE            NULL,
    [start_time]                   TIME (7)        NULL,
    [third_party_performance_code] CHAR (100)      NULL,
    [third_party_redirect_url]     CHAR (600)      NULL,
    [InsertedOn]                   DATETIME        NULL,
    [FileName]                     NVARCHAR (2000) NULL
);

