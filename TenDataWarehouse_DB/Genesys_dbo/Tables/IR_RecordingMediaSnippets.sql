CREATE TABLE [Genesys_dbo].[IR_RecordingMediaSnippets] (
    [PolicyRecordingId]  UNIQUEIDENTIFIER NOT NULL,
    [SnippetRecordingId] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_RecordingMediaSnippets] PRIMARY KEY CLUSTERED ([SnippetRecordingId] ASC)
);

