CREATE TABLE [Genesys_dbo].[IR_ArchiveContent] (
    [ArchivedDate]       DATETIME         NOT NULL,
    [ArchivedDateOffset] INT              NOT NULL,
    [ArchiveId]          UNIQUEIDENTIFIER NOT NULL,
    [RecordingId]        UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_ArchiveContent] PRIMARY KEY CLUSTERED ([ArchivedDate] ASC, [ArchiveId] ASC, [RecordingId] ASC)
);

