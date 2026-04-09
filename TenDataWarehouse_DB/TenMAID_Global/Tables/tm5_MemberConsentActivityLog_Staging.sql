CREATE TABLE [TenMAID_Global].[tm5_MemberConsentActivityLog_Staging] (
    [ActionPerformed]      NVARCHAR (100) NULL,
    [Channel]              INT            NULL,
    [ConsentId]            INT            NULL,
    [CreateBy]             INT            NULL,
    [CreateDate]           DATETIME       NULL,
    [ID]                   INT            NOT NULL,
    [IsAccepted]           BIT            NULL,
    [IsChannelSaved]       BIT            NULL,
    [IsGlobal]             BIT            NULL,
    [MemberId]             INT            NULL,
    [SchemeID]             INT            NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1)   NULL,
    [SYS_CHANGE_VERSION]   BIGINT         NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_MemberConsentActivityLog_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

