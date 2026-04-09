CREATE TABLE [TenMAID_US].[tm5_GlobalConsentDetails_Staging] (
    [ConsentDescription]   NVARCHAR (1500) NULL,
    [ConsentName]          NVARCHAR (200)  NULL,
    [CreateBy]             INT             NULL,
    [CreateDate]           DATETIME        NULL,
    [GlobalConsentID]      INT             NOT NULL,
    [IsActive]             BIT             NULL,
    [IsConsentRequired]    BIT             NULL,
    [SchemeId]             INT             NULL,
    [UpdateBy]             INT             NULL,
    [UpdateDate]           DATETIME        NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)    NULL,
    [SYS_CHANGE_VERSION]   BIGINT          NULL,
    CONSTRAINT [PK_TenMAID_US_tm5_GlobalConsentDetails_Staging] PRIMARY KEY CLUSTERED ([GlobalConsentID] ASC)
);

