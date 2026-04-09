CREATE TABLE [RedShift_hsbc_vi].[identifies] (
    [id]                      NVARCHAR (512) NULL,
    [received_at]             DATETIME2 (7)  NULL,
    [uuid]                    BIGINT         NULL,
    [context_library_version] NVARCHAR (512) NULL,
    [context_page_path]       NVARCHAR (512) NULL,
    [context_page_title]      NVARCHAR (512) NULL,
    [context_page_url]        NVARCHAR (512) NULL,
    [user_id]                 NVARCHAR (512) NULL,
    [context_ip]              NVARCHAR (512) NULL,
    [context_locale]          NVARCHAR (512) NULL,
    [context_user_agent]      NVARCHAR (512) NULL,
    [timestamp]               DATETIME2 (7)  NULL,
    [user_id_type]            NVARCHAR (512) NULL,
    [context_library_name]    NVARCHAR (512) NULL,
    [original_timestamp]      DATETIME2 (7)  NULL,
    [sent_at]                 DATETIME2 (7)  NULL,
    [uuid_ts]                 DATETIME2 (7)  NULL,
    [anonymous_id]            NVARCHAR (512) NULL,
    [context_page_referrer]   NVARCHAR (512) NULL,
    [context_page_search]     NVARCHAR (512) NULL
);

