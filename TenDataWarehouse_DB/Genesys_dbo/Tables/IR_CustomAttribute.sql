CREATE TABLE [Genesys_dbo].[IR_CustomAttribute] (
    [CustomAttributeNameId] INT              NOT NULL,
    [RecordingId]           UNIQUEIDENTIFIER NOT NULL,
    [Value]                 NVARCHAR (255)   NOT NULL,
    [Version]               INT              NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_CustomAttribute] PRIMARY KEY CLUSTERED ([CustomAttributeNameId] ASC, [RecordingId] ASC)
);

