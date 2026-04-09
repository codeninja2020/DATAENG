CREATE TABLE [Genesys_dbo].[IR_RecordingMedia] (
    [CallType]                     TINYINT          NULL,
    [Direction]                    TINYINT          NULL,
    [Duration]                     INT              NULL,
    [ExpirationDate]               DATETIME         NULL,
    [FileSize]                     INT              NULL,
    [FromConnValue]                NVARCHAR (255)   NULL,
    [InitiationPolicyName]         NVARCHAR (50)    NULL,
    [IsArchived]                   TINYINT          NOT NULL,
    [KeywordAgentScoreNegative]    INT              NULL,
    [KeywordAgentScorePositive]    INT              NULL,
    [KeywordCustomerScoreNegative] INT              NULL,
    [KeywordCustomerScorePositive] INT              NULL,
    [LineName]                     NVARCHAR (50)    NULL,
    [MediaKey]                     NVARCHAR (1024)  NULL,
    [MediaStatus]                  NVARCHAR (56)    NULL,
    [MediaType]                    SMALLINT         NOT NULL,
    [MediaURI]                     NVARCHAR (1024)  NULL,
    [NumAttachments]               SMALLINT         NULL,
    [QueueObjectIdKey]             VARCHAR (36)     NULL,
    [RecordingDate]                DATETIME2 (7)    NOT NULL,
    [RecordingDateOffset]          INT              NOT NULL,
    [RecordingId]                  UNIQUEIDENTIFIER NOT NULL,
    [RecordingType]                SMALLINT         NULL,
    [RelatedRecordingId]           UNIQUEIDENTIFIER NULL,
    [ScreenRecordedHostName]       NVARCHAR (255)   NULL,
    [StartEventCode]               INT              NOT NULL,
    [ToConnValue]                  NVARCHAR (255)   NULL,
    [Version]                      INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_RecordingMedia] PRIMARY KEY CLUSTERED ([RecordingId] ASC) WITH (DATA_COMPRESSION = PAGE)
);



