CREATE TABLE [Genesys_dbo].[RPT_custom_data] (
    [custom_data]           NVARCHAR (2048)  NULL,
    [custom_data_id]        UNIQUEIDENTIFIER NOT NULL,
    [description]           NVARCHAR (1024)  NULL,
    [encrypted]             INT              NOT NULL,
    [last_modified_dateUTC] DATETIME2 (7)    NOT NULL,
    [name]                  NVARCHAR (50)    NOT NULL,
    [report_id]             UNIQUEIDENTIFIER NOT NULL,
    [version]               SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_RPT_custom_data] PRIMARY KEY CLUSTERED ([custom_data_id] ASC)
);

