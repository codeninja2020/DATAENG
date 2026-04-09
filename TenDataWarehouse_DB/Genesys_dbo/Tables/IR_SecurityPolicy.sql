CREATE TABLE [Genesys_dbo].[IR_SecurityPolicy] (
    [ApplySql]         NVARCHAR (MAX)   NULL,
    [SecurityPolicyId] UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IR_SecurityPolicy] PRIMARY KEY CLUSTERED ([SecurityPolicyId] ASC)
);

