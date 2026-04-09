CREATE TABLE [Genesys_dbo].[IR_AccessControl] (
    [RecordingId]      UNIQUEIDENTIFIER NOT NULL,
    [SecurityPolicyId] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_AccessControl] PRIMARY KEY CLUSTERED ([RecordingId] ASC, [SecurityPolicyId] ASC)
);

