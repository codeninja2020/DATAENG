CREATE TABLE [Genesys_dbo].[IR_SocialMediaRecording] (
    [ChannelId]   NVARCHAR (128)   NOT NULL,
    [ChannelName] NVARCHAR (1024)  NOT NULL,
    [Page]        NVARCHAR (128)   NULL,
    [Platform]    SMALLINT         NOT NULL,
    [RecordingId] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_SocialMediaRecording] PRIMARY KEY CLUSTERED ([RecordingId] ASC)
);

