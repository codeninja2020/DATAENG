CREATE TABLE [TenMAID_US].[tm5_GlobalConsentDetails] (
    [ConsentDescription] NVARCHAR (1500) NULL,
    [ConsentName]        NVARCHAR (200)  NULL,
    [CreateBy]           INT             NULL,
    [CreateDate]         DATETIME        NULL,
    [GlobalConsentID]    INT             NOT NULL,
    [IsActive]           BIT             NULL,
    [IsConsentRequired]  BIT             NULL,
    [SchemeId]           INT             NOT NULL,
    [UpdateBy]           INT             NULL,
    [UpdateDate]         DATETIME        NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_GlobalConsentDetails] PRIMARY KEY CLUSTERED ([GlobalConsentID] ASC)
);

