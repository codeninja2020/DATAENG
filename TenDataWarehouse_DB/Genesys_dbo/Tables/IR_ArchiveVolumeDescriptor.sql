CREATE TABLE [Genesys_dbo].[IR_ArchiveVolumeDescriptor] (
    [ArchiveEndDT]   DATETIME2 (7)    NULL,
    [ArchiveId]      UNIQUEIDENTIFIER NOT NULL,
    [ArchiveStartDT] DATETIME2 (7)    NULL,
    [MediaURI]       NVARCHAR (1024)  NULL,
    [VolumeDT]       DATETIME2 (7)    NOT NULL,
    [VolumeDTOffset] INT              NOT NULL,
    [VolumeName]     NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_ArchiveVolumeDescriptor] PRIMARY KEY CLUSTERED ([ArchiveId] ASC)
);

