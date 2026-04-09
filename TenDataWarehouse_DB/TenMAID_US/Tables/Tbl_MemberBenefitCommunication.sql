CREATE TABLE [TenMAID_US].[Tbl_MemberBenefitCommunication] (
    [CommunicationID] INT      NULL,
    [DateCreated]     DATETIME NULL,
    [DateUpdated]     DATETIME NULL,
    [ID]              INT      NOT NULL,
    [MemberBenefitID] INT      NULL,
    CONSTRAINT [PK_TenMAID_US_Tbl_MemberBenefitCommunication] PRIMARY KEY CLUSTERED ([ID] ASC)
);

