CREATE TABLE [Genesys_dbo].[RPT_system_settings] (
    [first_day_of_week]     TINYINT          NOT NULL,
    [last_modified_dateUTC] DATETIME2 (7)    NOT NULL,
    [system_logo_file]      NVARCHAR (1024)  NULL,
    [system_settings_id]    UNIQUEIDENTIFIER NOT NULL,
    [timeout_period]        INT              NOT NULL,
    [version]               SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_RPT_system_settings] PRIMARY KEY CLUSTERED ([system_settings_id] ASC)
);

