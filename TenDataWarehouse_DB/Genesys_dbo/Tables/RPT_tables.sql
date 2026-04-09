CREATE TABLE [Genesys_dbo].[RPT_tables] (
    [ic_datasource]         NVARCHAR (100)   NOT NULL,
    [last_modified_dateUTC] DATETIME2 (7)    NOT NULL,
    [report_id]             UNIQUEIDENTIFIER NOT NULL,
    [seqno]                 TINYINT          NOT NULL,
    [table_id]              UNIQUEIDENTIFIER NOT NULL,
    [table_name]            NVARCHAR (50)    NOT NULL,
    [version]               SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_RPT_tables] PRIMARY KEY CLUSTERED ([table_id] ASC)
);

