CREATE TABLE [RedShift_coutts_production].[member_events_location_filter_cleared] (
    [id]                      NVARCHAR (512) NULL,
    [received_at]             DATETIME2 (6)  NULL,
    [uuid]                    BIGINT         NULL,
    [anonymous_id]            NVARCHAR (512) NULL,
    [context_ip]              NVARCHAR (512) NULL,
    [context_library_version] NVARCHAR (512) NULL,
    [context_page_search]     NVARCHAR (512) NULL,
    [timestamp]               DATETIME2 (6)  NULL,
    [context_library_name]    NVARCHAR (512) NULL,
    [context_page_path]       NVARCHAR (512) NULL,
    [context_page_url]        NVARCHAR (512) NULL,
    [context_user_agent]      NVARCHAR (512) NULL,
    [event_text]              NVARCHAR (512) NULL,
    [original_timestamp]      DATETIME2 (6)  NULL,
    [user_id]                 NVARCHAR (512) NULL,
    [context_page_title]      NVARCHAR (512) NULL,
    [event]                   NVARCHAR (512) NULL,
    [sent_at]                 DATETIME2 (6)  NULL,
    [uuid_ts]                 DATETIME2 (6)  NULL,
    [context_locale]          NVARCHAR (512) NULL,
    [context_page_referrer]   NVARCHAR (512) NULL
);

