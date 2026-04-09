CREATE TABLE [Genesys_dbo].[RPT_flexible_columns] (
    [column_name]           NVARCHAR (50)    NOT NULL,
    [description]           NVARCHAR (1024)  NULL,
    [description_resource]  NVARCHAR (1024)  NULL,
    [flexible_columns_id]   UNIQUEIDENTIFIER NOT NULL,
    [last_modified_dateUTC] DATETIME2 (7)    NOT NULL,
    [name]                  NVARCHAR (50)    NOT NULL,
    [name_resource]         NVARCHAR (50)    NULL,
    [report_id]             UNIQUEIDENTIFIER NOT NULL,
    [version]               SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_RPT_flexible_columns] PRIMARY KEY CLUSTERED ([flexible_columns_id] ASC)
);

