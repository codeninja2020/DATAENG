CREATE TABLE [TenMAID_Global].[tm5_MemberConsent] (
    [Channel]          INT      NULL,
    [ConsentId]        INT      NOT NULL,
    [CreateBy]         INT      NULL,
    [CreateDate]       DATETIME NULL,
    [ForeignConsentId] INT      NULL,
    [ID]               INT      NOT NULL,
    [IsAccepted]       BIT      NULL,
    [IsChannelSaved]   BIT      NULL,
    [IsGlobal]         BIT      NULL,
    [MemberId]         INT      NOT NULL,
    [SchemeID]         INT      NULL,
    [UpdateBy]         INT      NULL,
    [UpdateDate]       DATETIME NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_MemberConsent] PRIMARY KEY CLUSTERED ([ID] ASC)
);

