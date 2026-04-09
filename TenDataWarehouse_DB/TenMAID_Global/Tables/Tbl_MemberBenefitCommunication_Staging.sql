CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitCommunication_Staging] (
    [CommunicationID]      INT          NULL,
    [DateCreated]          DATETIME     NULL,
    [DateUpdated]          DATETIME     NULL,
    [ID]                   INT          NOT NULL,
    [MemberBenefitID]      INT          NULL,
    [SYS_CHANGE_OPERATION] NVARCHAR (1) NULL,
    [SYS_CHANGE_VERSION]   BIGINT       NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitCommunication_Staging] PRIMARY KEY CLUSTERED ([ID] ASC)
);

