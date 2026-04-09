CREATE TABLE [TenMAID_Global].[tm5_MemberConsentActivityLog] (
    [ActionPerformed] NVARCHAR (100) NULL,
    [Channel]         INT            NULL,
    [ConsentId]       INT            NOT NULL,
    [CreateBy]        INT            NULL,
    [CreateDate]      DATETIME       NULL,
    [ID]              INT            NOT NULL,
    [IsAccepted]      BIT            NULL,
    [IsChannelSaved]  BIT            NULL,
    [IsGlobal]        BIT            NULL,
    [MemberId]        INT            NOT NULL,
    [SchemeID]        INT            NULL,
    CONSTRAINT [PK_TenMAID_Global_tm5_MemberConsentActivityLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);

