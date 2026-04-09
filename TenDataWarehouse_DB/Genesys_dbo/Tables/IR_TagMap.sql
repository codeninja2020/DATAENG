CREATE TABLE [Genesys_dbo].[IR_TagMap] (
    [KeywordSetName] NVARCHAR (128)   NULL,
    [RecordingId]    UNIQUEIDENTIFIER NOT NULL,
    [TagId]          INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_TagMap] PRIMARY KEY CLUSTERED ([RecordingId] ASC, [TagId] ASC)
);

