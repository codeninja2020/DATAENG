CREATE TABLE [Genesys_dbo].[RPT_categories] (
    [category_id]           UNIQUEIDENTIFIER NOT NULL,
    [description]           NVARCHAR (1024)  NULL,
    [description_resource]  NVARCHAR (1024)  NULL,
    [friendly_key]          NVARCHAR (50)    NULL,
    [is_visible]            BIT              NOT NULL,
    [last_modified_dateUTC] DATETIME2 (7)    NOT NULL,
    [license]               NVARCHAR (500)   NULL,
    [name]                  NVARCHAR (50)    NOT NULL,
    [name_resource]         NVARCHAR (50)    NULL,
    [seqno]                 TINYINT          NOT NULL,
    [version]               SMALLINT         NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_RPT_categories] PRIMARY KEY CLUSTERED ([category_id] ASC)
);

