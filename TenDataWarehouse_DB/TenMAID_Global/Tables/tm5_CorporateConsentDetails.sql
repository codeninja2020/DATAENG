CREATE TABLE [TenMAID_Global].[tm5_CorporateConsentDetails] (
    [ConsentDescription] NVARCHAR (1500) NULL,
    [ConsentID]          INT             NOT NULL,
    [ConsentName]        NVARCHAR (200)  NULL,
    [CreateBy]           INT             NULL,
    [CreateDate]         DATETIME        NULL,
    [IsActive]           BIT             NULL,
    [IsConsentRequired]  BIT             NULL,
    [SchemeId]           INT             NOT NULL,
    [UpdateBy]           INT             NULL,
    [UpdateDate]         DATETIME        NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_CorporateConsentDetails] PRIMARY KEY CLUSTERED ([ConsentID] ASC)
);

