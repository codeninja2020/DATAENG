CREATE TABLE [Genesys_dbo].[RPT_metadata_updates] (
    [column_name]            NVARCHAR (30)    NOT NULL,
    [id]                     UNIQUEIDENTIFIER NOT NULL,
    [release_version]        NVARCHAR (10)    NOT NULL,
    [table_name]             NVARCHAR (30)    NOT NULL,
    [value]                  NVARCHAR (MAX)   NOT NULL,
    [RPT_metadata_updatesID] INT              IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_RPT_RPT_metadata_updates_RPT_metadata_updatesID] PRIMARY KEY CLUSTERED ([RPT_metadata_updatesID] ASC)
);

