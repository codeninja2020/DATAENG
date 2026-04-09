CREATE TABLE [Genesys_dbo].[RPT_sections] (
    [is_visible]            BIT              NOT NULL,
    [last_modified_dateUTC] DATETIME2 (7)    NOT NULL,
    [report_id]             UNIQUEIDENTIFIER NOT NULL,
    [section_id]            UNIQUEIDENTIFIER NOT NULL,
    [section_name]          NVARCHAR (50)    NOT NULL,
    [version]               SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_RPT_sections] PRIMARY KEY CLUSTERED ([section_id] ASC)
);

