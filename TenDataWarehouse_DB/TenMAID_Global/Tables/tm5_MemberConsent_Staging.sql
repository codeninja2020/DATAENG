CREATE TABLE [TenMAID_Global].[tm5_MemberConsent_Staging] (
    [Channel]              INT          NULL,
    [ConsentId]            INT          NULL,
    [CreateBy]             INT          NULL,
    [CreateDate]           DATETIME     NULL,
    [ForeignConsentId]     INT          NULL,
    [ID]                   INT          NOT NULL,
    [IsAccepted]           BIT          NULL,
    [IsChannelSaved]       BIT          NULL,
    [IsGlobal]             BIT          NULL,
    [MemberId]             INT          NULL,
    [SchemeID]             INT          NULL,
    [UpdateBy]             INT          NULL,
    [UpdateDate]           DATETIME     NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_MemberConsent_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

