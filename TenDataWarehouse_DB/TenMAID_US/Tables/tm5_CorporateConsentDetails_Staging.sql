CREATE TABLE [TenMAID_US].[tm5_CorporateConsentDetails_Staging] (
    [ConsentDescription]   NVARCHAR (1500) NULL,
    [ConsentID]            INT             NOT NULL,
    [ConsentName]          NVARCHAR (200)  NULL,
    [CreateBy]             INT             NULL,
    [CreateDate]           DATETIME        NULL,
    [IsActive]             BIT             NULL,
    [IsConsentRequired]    BIT             NULL,
    [SchemeId]             INT             NULL,
    [UpdateBy]             INT             NULL,
    [UpdateDate]           DATETIME        NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_CorporateConsentDetails_Staging] PRIMARY KEY CLUSTERED ([ConsentID] ASC)
);

