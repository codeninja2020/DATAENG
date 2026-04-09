CREATE TABLE [Genesys_dbo].[IALicenseAttributeLog] (
    [CallCallback]            BIT      NOT NULL,
    [Chat]                    BIT      NOT NULL,
    [Email]                   BIT      NOT NULL,
    [EnhancedIAChangeLogId]   INT      NOT NULL,
    [Generic]                 BIT      NOT NULL,
    [IALicenseAttributeLogId] INT      NOT NULL,
    [IsActive]                BIT      NOT NULL,
    [IsAssignable]            BIT      NOT NULL,
    [License]                 SMALLINT NOT NULL,
    CONSTRAINT [PK_Genesys_dbo_IALicenseAttributeLog] PRIMARY KEY CLUSTERED ([IALicenseAttributeLogId] ASC)
);

