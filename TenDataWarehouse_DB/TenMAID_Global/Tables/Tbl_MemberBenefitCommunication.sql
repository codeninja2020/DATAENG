CREATE TABLE [TenMAID_Global].[Tbl_MemberBenefitCommunication] (
    [CommunicationID] INT      NULL,
    [DateCreated]     DATETIME NULL,
    [DateUpdated]     DATETIME NULL,
    [ID]              INT      NOT NULL,
    [MemberBenefitID] INT      NULL,
    CONSTRAINT [PK_TenMAID_Global_Tbl_MemberBenefitCommunication] PRIMARY KEY CLUSTERED ([ID] ASC)
);

